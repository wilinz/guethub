use aes::Aes128;
use cipher::{BlockEncrypt, KeyInit};

pub struct AesCfb {
    pub key: [u8; 16],
    pub iv: [u8; 16],
}

impl AesCfb {

    #[flutter_rust_bridge::frb(sync)]
    pub fn new(key: &[u8], iv: &[u8]) -> Self {
        assert!(key.len() == 16 && iv.len() == 16, "Key and IV must be 16 bytes");
        let mut key_arr = [0u8; 16];
        let mut iv_arr = [0u8; 16];
        key_arr.copy_from_slice(key);
        iv_arr.copy_from_slice(iv);
        Self { key: key_arr, iv: iv_arr }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn encrypt(&self, data: &[u8]) -> Vec<u8> {
        let mut iv = self.iv;
        let mut encrypted = Vec::with_capacity(data.len());

        for chunk in data.chunks(16) {
            // Encrypt the IV
            let mut block = iv.clone();
            self.aes_encrypt(&mut block);

            // XOR the plaintext with the encrypted IV
            let cipher_chunk: Vec<u8> = chunk.iter().zip(block.iter()).map(|(&p, &o)| p ^ o).collect();
            encrypted.extend_from_slice(&cipher_chunk);

            // Update the IV for the next block
            if chunk.len() == 16 {
                iv.copy_from_slice(&cipher_chunk);
            } else {
                // For the last incomplete block, only update the relevant part of the IV
                for (i, &byte) in cipher_chunk.iter().enumerate() {
                    iv[i] = byte;
                }
            }
        }

        encrypted
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn decrypt(&self, data: &[u8]) -> Vec<u8> {
        let mut iv = self.iv;
        let mut decrypted = Vec::with_capacity(data.len());

        for chunk in data.chunks(16) {
            // Encrypt the IV
            let mut block = iv.clone();
            self.aes_encrypt(&mut block);

            // XOR the ciphertext with the encrypted IV
            let plain_chunk: Vec<u8> = chunk.iter().zip(block.iter()).map(|(&c, &o)| c ^ o).collect();
            decrypted.extend_from_slice(&plain_chunk);

            // Update the IV for the next block
            if chunk.len() == 16 {
                iv.copy_from_slice(chunk);
            } else {
                // For the last incomplete block, only update the relevant part of the IV
                for (i, &byte) in chunk.iter().enumerate() {
                    iv[i] = byte;
                }
            }
        }

        decrypted
    }

    #[flutter_rust_bridge::frb(ignore)]
    fn aes_encrypt(&self, block: &mut [u8; 16]) {
        // Here you would implement the AES encryption algorithm.
        // For simplicity, we'll use the `aes` crate's implementation.
        use cipher::generic_array::GenericArray;
        let cipher = Aes128::new(GenericArray::from_slice(&self.key));
        let mut block_array = GenericArray::from_mut_slice(block);
        cipher.encrypt_block(&mut block_array);
    }
}
