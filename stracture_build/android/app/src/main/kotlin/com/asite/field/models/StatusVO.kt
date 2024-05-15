package com.asite.field.models

data class StatusVO(
    val bgColor: String,
    val fontColor: String,
    val generateURI: Boolean,
    val statusCount: Int,
    val statusId: Int,
    val statusName: String,
    val statusTypeId: Int
)