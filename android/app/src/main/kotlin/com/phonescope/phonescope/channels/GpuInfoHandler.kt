package com.phonescope.phonescope.channels

import android.content.Context
import android.content.pm.PackageManager
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES20
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GpuInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getGpuInfo" -> {
                try {
                    val info = getGpuDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("GPU_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getGpuDetails(): Map<String, Any?> {
        val glData = getGlStrings()
        val pm = context.packageManager

        val hasOpenGlEs30 = pm.hasSystemFeature(PackageManager.FEATURE_OPENGLES_EXTENSION_PACK)
        val hasVulkan = pm.hasSystemFeature(PackageManager.FEATURE_VULKAN_HARDWARE_LEVEL)
        val vulkanVersion = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val vulkanFeature = pm.systemAvailableFeatures.firstOrNull {
                it.name == PackageManager.FEATURE_VULKAN_HARDWARE_VERSION
            }
            vulkanFeature?.version ?: 0
        } else {
            0
        }

        return mapOf(
            "renderer" to glData["renderer"],
            "vendor" to glData["vendor"],
            "version" to glData["version"],
            "extensionsCount" to glData["extensionsCount"],
            "extensions" to glData["extensions"],
            "hasVulkan" to hasVulkan,
            "vulkanVersionCode" to vulkanVersion,
            "hasOpenGlEsExtensionPack" to hasOpenGlEs30
        )
    }

    private fun getGlStrings(): Map<String, Any?> {
        var renderer = "Unavailable"
        var vendor = "Unavailable"
        var version = "Unavailable"
        val extensionsList = mutableListOf<String>()

        try {
            val dpy: EGLDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
            val vers = IntArray(2)
            EGL14.eglInitialize(dpy, vers, 0, vers, 1)

            val configAttr = intArrayOf(
                EGL14.EGL_COLOR_BUFFER_TYPE, EGL14.EGL_RGB_BUFFER,
                EGL14.EGL_LEVEL, 0,
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT,
                EGL14.EGL_NONE
            )
            val configs = arrayOfNulls<EGLConfig>(1)
            val numConfig = IntArray(1)
            EGL14.eglChooseConfig(dpy, configAttr, 0, configs, 0, 1, numConfig, 0)

            if (numConfig[0] > 0 && configs[0] != null) {
                val surfAttr = intArrayOf(
                    EGL14.EGL_WIDTH, 1,
                    EGL14.EGL_HEIGHT, 1,
                    EGL14.EGL_NONE
                )
                val surf: EGLSurface = EGL14.eglCreatePbufferSurface(dpy, configs[0], surfAttr, 0)
                val ctxAttr = intArrayOf(
                    EGL14.EGL_CONTEXT_CLIENT_VERSION, 2,
                    EGL14.EGL_NONE
                )
                val ctx: EGLContext = EGL14.eglCreateContext(dpy, configs[0], EGL14.EGL_NO_CONTEXT, ctxAttr, 0)

                EGL14.eglMakeCurrent(dpy, surf, surf, ctx)

                renderer = GLES20.glGetString(GLES20.GL_RENDERER) ?: "Unavailable"
                vendor = GLES20.glGetString(GLES20.GL_VENDOR) ?: "Unavailable"
                version = GLES20.glGetString(GLES20.GL_VERSION) ?: "Unavailable"

                val rawExtensions = GLES20.glGetString(GLES20.GL_EXTENSIONS) ?: ""
                if (rawExtensions.isNotEmpty()) {
                    extensionsList.addAll(rawExtensions.split(" ").filter { it.isNotBlank() })
                }

                EGL14.eglMakeCurrent(dpy, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
                EGL14.eglDestroyContext(dpy, ctx)
                EGL14.eglDestroySurface(dpy, surf)
            }
            EGL14.eglTerminate(dpy)
        } catch (_: Exception) {
            // Fallback gracefully
        }

        return mapOf(
            "renderer" to renderer,
            "vendor" to vendor,
            "version" to version,
            "extensionsCount" to extensionsList.size,
            "extensions" to extensionsList
        )
    }
}
