package com.asite.field.models

data class Recipient(
    val distListId: Int,
    val dueDays: Int,
    val generateURI: Boolean,
    val projectId: String,
    val userID: String
)