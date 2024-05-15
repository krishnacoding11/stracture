package com.asite.field.models

data class LocationDetailVO(
    val annotationId: String,
    val coordinates: String,
    val docId: String,
    val folderId: String,
    val generateURI: Boolean,
    val hasChildLocation: Boolean,
    val isCalibrated: Boolean,
    val isFileAssociated: Boolean,
    val isLocationActive: Boolean,
    val isPFSite: Boolean,
    val locationId: Int,
    val locationPath: String,
    val parentLocationId: Int,
    val projectId: String,
    val revisionId: String,
    val siteId: Int
)