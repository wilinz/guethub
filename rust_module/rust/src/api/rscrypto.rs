use base64::Engine;
use hex::{self, decode as hex_decode, encode as hex_encode};

use rand::distr::Alphanumeric;
use rand::{rng, Rng};
use block_modes::{BlockMode, Cbc};
use std::str;
use aes::{Aes128, NewBlockCipher};
use block_modes::block_padding::Pkcs7;
use cipher::KeyInit;
use crate::api::cfbcrypto::AesCfb;

#[flutter_rust_bridge::frb(sync)]
pub fn get_encrypt_web_vpn_host(plaintext: &str, key: &[u8], iv: &[u8]) -> String {
    let encrypted = AesCfb::new(key, iv).encrypt(plaintext.as_bytes());
    hex_encode(encrypted)
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_decrypt_web_vpn_host(ciphertext: &str, key: &[u8], iv: &[u8]) -> String {
    let ct = hex_decode(ciphertext).expect("Invalid hex");
    let decrypted = AesCfb::new(key, iv).decrypt(&ct);
    String::from_utf8(decrypted).expect("Invalid UTF-8")
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_web_vpn_url(url: &str, key: &[u8], iv: &[u8], vpn_base_url: &str) -> String {
    let parts: Vec<&str> = url.splitn(2, "://").collect();
    if parts.len() < 2 {
        return String::new();
    }
    let pro = parts[0];
    let add = parts[1];

    let host_path: Vec<&str> = add.splitn(2, '/').collect();
    let host_part = host_path[0];
    let fold_part = if host_path.len() > 1 {
        host_path[1]
    } else {
        ""
    };

    let (domain, port_suffix) = match host_part.split_once(':') {
        Some((d, p)) => (d, format!("-{}", p)),
        None => (host_part, String::new()),
    };

    let cph = get_encrypt_web_vpn_host(domain, key, iv);
    let iv_hex = hex_encode(iv);

    format!(
        "{}/{}{}/{}{}/{}",
        vpn_base_url, pro, port_suffix, iv_hex, cph, fold_part
    )
}

#[flutter_rust_bridge::frb(sync)]
pub fn get_web_vpn_ordinary_url(url: &str, key: &[u8], iv: &[u8]) -> String {
    let parts: Vec<&str> = url.split('/').collect();
    if parts.len() < 5 {
        return String::new();
    }
    let pro = parts[3];
    let key_cph = parts[4];

    let hex_iv = hex_encode(iv);

    if key_cph.len() >= 16 && &key_cph[..16] == &hex_iv {
        if key_cph.len() >= 32 {
            println!("error: key_cph: {}", &key_cph[..32]);
        }
        String::new()
    } else {
        if key_cph.len() < 32 {
            return String::new();
        }
        let encrypted_host = &key_cph[32..];
        let hostname = get_decrypt_web_vpn_host(encrypted_host, key, iv);
        let fold = if parts.len() > 5 {
            parts[5..].join("/")
        } else {
            String::new()
        };
        let pro_parts: Vec<&str> = pro.splitn(2, '-').collect();
        let (protocol, port) = if pro_parts.len() > 1 {
            (pro_parts[0], format!(":{}", pro_parts[1]))
        } else {
            (pro_parts[0], String::new())
        };
        format!("{}://{}{}/{}", protocol, hostname, port, fold)
    }
}

type Aes128Cbc = Cbc<Aes128, Pkcs7>;

#[flutter_rust_bridge::frb(sync)]
// 加密函数
pub fn encrypt_aes_128_cbc_64prefix(plain: &str, key: &[u8]) -> String {
    if key.len() != 16 && key.len() != 24 && key.len() != 32 {
        panic!("Key must be 16, 24, or 32 bytes long");
    }

    // 生成随机的 IV（16 字节）
    let mut iv = [0u8; 16];
    rng().fill(&mut iv);

    // 生成 64 字节的随机字符串

    let random_str: String = rng()
        .sample_iter(&Alphanumeric)
        .take(64)
        .map(char::from)
        .collect();

    // 拼接随机字符串和密码
    let plaintext = format!("{}{}", random_str, plain);

    let cipher = Aes128Cbc::new_from_slices(&key, &iv).expect("Aes128Cbc::new_from_slices failed");
    let plain = plaintext.as_bytes();
    let ciphertext = cipher.encrypt_vec(plain);
    base64::engine::general_purpose::STANDARD.encode(&ciphertext)
}

#[flutter_rust_bridge::frb(sync)]
// 解密函数
pub fn decrypt_aes_128_cbc_64prefix(encrypted_base64: &str, key: &[u8]) -> String {
    // 将密钥转换为字节数组
    if key.len() != 16 && key.len() != 24 && key.len() != 32 {
        panic!("Key must be 16, 24, or 32 bytes long");
    }

    // 解码 Base64
    let encrypted_data = base64::engine::general_purpose::STANDARD
        .decode(encrypted_base64)
        .expect("Invalid Base64");

    // 生成随机的 IV（16 字节）
    let mut iv = [0u8; 16];
    rng().fill(&mut iv);

    let cipher = Aes128Cbc::new_from_slices(&key, &iv).unwrap();
    let decrypted = cipher.decrypt_vec(&encrypted_data).expect("Decryption failed").split_off(64);
    String::from_utf8(decrypted).expect("Invalid UTF-8")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
