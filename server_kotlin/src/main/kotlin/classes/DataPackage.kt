package com.perceivers25.betalk.classes

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.*

/**
 * Data package is a class that defines a data package in the Betalk Protocol able to represent a login or a message.
 * At anytime message or login name should be specified.
 *
 * @param id The universally unique identifier of the data package
 * @param message The message itself if  type is message
 * @param loginName The user login if type is login
 * @see Server
 */
@Serializable
class DataPackage(val id: String, val type: DataPackageType, val message: Message?, val loginName: String?) {

    init {
        assert(message != null || loginName != null)
        assert(!(type == DataPackageType.Message && message == null))
        assert(!(type == DataPackageType.Login && loginName == null))
    }

    fun toJson(): String {
        val format = Json { encodeDefaults = true }
        return format.encodeToString(this);
    }

    companion object {
        fun fromJson(jsonString: String): DataPackage {
            return Json.decodeFromString<DataPackage>(jsonString)
        }

        fun newMessageDataPackage(message: Message): DataPackage {
            return DataPackage(
                UUID.randomUUID().toString(), DataPackageType.Message, message, null,
            )
        }
    }

    @Serializable
    enum class DataPackageType {
        @SerialName("login")
        Login,

        @SerialName("message")
        Message,
    }
}