package com.perceivers25.betalk.classes

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter
import java.util.*

@Serializable
class Message(
    val messageID: String,
    val messageAuthor: String?,
    val messageTextContent: String?,
    val messageFileContent: ByteArray?,
    val time: String,
    val type: MessageType,
) {
    init {
        assert(messageTextContent != null || messageFileContent != null)
    }

    @Serializable
    enum class MessageType {
        @SerialName("user-message")
        UserMessage,

        @SerialName("system-message")
        SystemMessage,
    }

    companion object {
        fun newSystemMessage(messageTextContent: String): Message {
            return Message(
                UUID.randomUUID().toString(), null, messageTextContent, null, DateTimeFormatter
                    .ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSS")
                    .withZone(ZoneOffset.UTC)
                    .format(Instant.now()), MessageType.SystemMessage
            )
        }
    }
}