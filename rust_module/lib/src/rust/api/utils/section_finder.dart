// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `get_section_times`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `SectionTime`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `fmt`
// These functions are ignored (category: IgnoreBecauseExplicitAttribute): `find_closest_section`

int? findClosestSectionFromRfc3339(
        {required String startTimeStr, required String endTimeStr}) =>
    RustLib.instance.api
        .crateApiUtilsSectionFinderFindClosestSectionFromRfc3339(
            startTimeStr: startTimeStr, endTimeStr: endTimeStr);
