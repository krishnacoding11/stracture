package com.asite.asite_plugins

import android.annotation.SuppressLint
import android.os.Build
import android.util.Base64
import androidx.annotation.RequiresApi
import java.nio.ByteBuffer
import java.security.NoSuchAlgorithmException
import java.security.SecureRandom
import java.util.*
import javax.crypto.Cipher
import javax.crypto.NoSuchPaddingException
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * Created by Chandresh Patel on 09-08-2022.
 */
@SuppressLint("NewApi")
class CryptoHelper {
    private var cipher: Cipher? = null

    @Throws(Exception::class)
    private fun encryptInternalECB(text: String?): ByteArray {
        if (text == null || text.isEmpty()) {
            throw Exception("Empty string")
        }
        val keyDigestBytes = String(
            Base64.decode(
                keyValue!!.toByteArray(),
                Base64.NO_WRAP
            )
        ).toByteArray(charset(DEFAULT_CODING))
        val skc =
            SecretKeySpec(keyDigestBytes, ALGORITHM)
        val cipher =
            Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, skc)
        return cipher.doFinal(text.toByteArray(charset(DEFAULT_CODING)))
    }

    @Throws(Exception::class)
    private fun decryptInternalECB(code: String?): ByteArray {
        if (code == null || code.isEmpty()) {
            throw Exception("Empty string")
        }
        val decrypted: ByteArray = try {
            val keyDigestBytes =
                String(Base64.decode(keyValue!!.toByteArray(), Base64.NO_WRAP)).toByteArray(
                    charset(
                        DEFAULT_CODING
                    )
                )
            val skc = SecretKeySpec(keyDigestBytes, ALGORITHM)
            cipher!!.init(Cipher.DECRYPT_MODE, skc)
            cipher!!.doFinal(Base64.decode(code, Base64.DEFAULT))
        } catch (e: Exception) {
            throw Exception("[decrypt] " + e.message)
        }
        return decrypted
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @Throws(Exception::class)
    private fun encryptInternalCTR(text: String?): String {

        val encrypted: String

        //ENCODE part
        val ivGenerator = SecureRandom()
        val encryptionKeyRaw = keyValue?.toByteArray()
        //aes-128=16bit IV block size
        val ivLength = 16
        val iv = ByteArray(ivLength)
        //generate random vector
        ivGenerator.nextBytes(iv)

        if (text == null || text.isEmpty()) {
            throw Exception("Empty string")
        }
        try {
            val encryptionCipher = Cipher.getInstance("AES/CTR/NoPadding")
            encryptionCipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(encryptionKeyRaw, "AES"), IvParameterSpec(iv))
            //encrypt
            val cipherText = encryptionCipher.doFinal(text.toByteArray())

            val byteBuffer = ByteBuffer.allocate(ivLength + cipherText.size)
            //storing IV in first part of whole message
            byteBuffer.put(iv)
            //store encrypted bytes
            byteBuffer.put(cipherText)
            //concat it to result message
            val cipherMessage = byteBuffer.array()
            //and encrypt to base64 to get readable value
            encrypted = String(java.util.Base64.getEncoder().encode(cipherMessage))
            print("Encrypted $encrypted")
            return encrypted
        } catch (e: Exception) {
            throw IllegalStateException(e)
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @Throws(Exception::class)
    private fun decryptInternalCTR(encryptedString: String?): String {

        val decrypted: String
        val ivGenerator = SecureRandom()
        val encryptionKeyRaw = keyValue?.toByteArray()
        //aes-128=16bit IV block size
        val ivLength = 16
        var iv = ByteArray(ivLength)
        //generate random vector
        ivGenerator.nextBytes(iv)

        if (encryptedString == null || encryptedString.isEmpty()) {
            throw Exception("Empty string")
        }
        try {
            //decoding from base64
            val cipherMessageArr = java.util.Base64.getDecoder().decode(encryptedString)
            //retrieving IV from message
            iv = Arrays.copyOfRange(cipherMessageArr, 0, ivLength)
            //retrieving encrypted value from end of message
            val cipherText = Arrays.copyOfRange(cipherMessageArr, ivLength, cipherMessageArr.size)
            val decryptionCipher = Cipher.getInstance("AES/CTR/NoPadding")
            val ivSpec = IvParameterSpec(iv)
            val secretKeySpec = SecretKeySpec(encryptionKeyRaw, "AES")
            decryptionCipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivSpec)
            //decrypt
            val finalCipherText = decryptionCipher.doFinal(cipherText)
            //converting to string
            val finalDecryptedValue = String(finalCipherText)
            decrypted = finalDecryptedValue
        } catch (e: Exception) {
            throw IllegalStateException(e)
        }
        return decrypted
    }

    companion object {
        const val DEFAULT_CODING = "UTF-8"
        const val ALGORITHM = "AES"
        const val TRANSFORMATION = "AES/ECB/PKCS5Padding"
        var keyValue: String? = BuildConfig.PREFERENCE_KEY
        enum class EncryptionAlgorithm {
            ECB, CTR
        }
        @Throws(Exception::class)
        fun encrypt(valueToEncrypt: String?, encryptionAlgorithm: EncryptionAlgorithm): String {
            val enc = CryptoHelper()
            if(encryptionAlgorithm == EncryptionAlgorithm.ECB) {
                return Base64.encodeToString(enc.encryptInternalECB(valueToEncrypt), Base64.DEFAULT)
            } else if(encryptionAlgorithm == EncryptionAlgorithm.CTR) {
               return enc.encryptInternalCTR(valueToEncrypt)
            }
            return ""
        }

        @Throws(Exception::class)
        fun decrypt(valueToDecrypt: String?, encryptionAlgorithm: EncryptionAlgorithm): String {
            val enc = CryptoHelper()
            if(encryptionAlgorithm == EncryptionAlgorithm.ECB) {
                return String(enc.decryptInternalECB(valueToDecrypt))
            } else if(encryptionAlgorithm == EncryptionAlgorithm.CTR) {
                return enc.decryptInternalCTR(valueToDecrypt)
            }
            return ""
        }
    }

    init {
        try {
            cipher = Cipher.getInstance(TRANSFORMATION)
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
        } catch (e: NoSuchPaddingException) {
            e.printStackTrace()
        }
    }
}

