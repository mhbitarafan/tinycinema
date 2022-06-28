package com.example.tinycinema.mpv

import `is`.xyz.mpv.MPVLib
import android.content.Context
import android.util.Log
import android.os.Build
import android.os.Environment
import android.view.*
import `is`.xyz.mpv.MPVLib.mpvFormat.*

class MPVView(context: Context) : SurfaceView(context),
    SurfaceHolder.Callback {
    fun initialize(configDir: String) {
        MPVLib.create(this.context)
        MPVLib.setOptionString("config", "yes")
        MPVLib.setOptionString("config-dir", configDir)
        initOptions() // do this before init() so user-supplied config can override our choices
        MPVLib.init()
        // certain options are hardcoded:
        MPVLib.setOptionString("save-position-on-quit", "yes")
        MPVLib.setOptionString("force-window", "no")

        holder.addCallback(this)
        observeProperties()
    }

    private fun initOptions() {
        // vo: set display fps as reported by android
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val disp = wm.defaultDisplay
            val refreshRate = disp.mode.refreshRate
            Log.v(TAG, "Display ${disp.displayId} reports FPS of $refreshRate")
            MPVLib.setOptionString("override-display-fps", refreshRate.toString())
        } else {
            Log.v(
                TAG, "Android version too old, disabling refresh rate functionality " +
                        "(${Build.VERSION.SDK_INT} < ${Build.VERSION_CODES.M})"
            )
        }

        // set more options

        MPVLib.setOptionString("profile", "sw-fast")
        MPVLib.setOptionString("hwdec", "auto")
        MPVLib.setOptionString("interpolation", "no")
        MPVLib.setOptionString("ytdl", "no")
        MPVLib.setOptionString("vo", "gpu")
        MPVLib.setOptionString("gpu-context", "android")
        MPVLib.setOptionString("hwdec-codecs", "h264,hevc,mpeg4,mpeg2video,vp8,vp9")
        MPVLib.setOptionString("ao", "audiotrack,opensles")
        MPVLib.setOptionString("tls-verify", "yes")
        MPVLib.setOptionString("tls-ca-file", "${this.context.filesDir.path}/cacert.pem")
        MPVLib.setOptionString("input-default-bindings", "yes")
        // Limit demuxer cache since the defaults are too high for mobile devices
        val cacheMegs = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) 64 else 32
        MPVLib.setOptionString("demuxer-max-bytes", "${cacheMegs * 1024 * 1024}")
        MPVLib.setOptionString("demuxer-max-back-bytes", "${cacheMegs * 1024 * 1024}")
        //
        val screenshotDir =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        screenshotDir.mkdirs()
        MPVLib.setOptionString("screenshot-directory", screenshotDir.path)
        // DR is known to ruin performance at least on Exynos devices, see #508
        MPVLib.setOptionString("vd-lavc-dr", "no")
    }

    fun playFile(filePath: String) {
        this.filePath = filePath
    }

    // Called when back button is pressed, or app is shutting down
    fun destroy() {
        // Disable surface callbacks to avoid using unintialized mpv state
        holder.removeCallback(this)

        MPVLib.destroy()
    }

    private fun observeProperties() {
        // This observes all properties needed by MPVView, MPVActivity or other classes
        data class Property(val name: String, val format: Int = MPV_FORMAT_NONE)

        val p = arrayOf(
            Property("time-pos", MPV_FORMAT_INT64),
            Property("duration", MPV_FORMAT_INT64),
            Property("pause", MPV_FORMAT_FLAG),
            Property("track-list"),
            Property("video-params"),
            Property("playlist-pos", MPV_FORMAT_INT64),
            Property("playlist-count", MPV_FORMAT_INT64),
            Property("video-format"),
            Property("media-title", MPV_FORMAT_STRING),
            Property("metadata/by-key/Artist", MPV_FORMAT_STRING),
            Property("metadata/by-key/Album", MPV_FORMAT_STRING),
            Property("loop-playlist"),
            Property("loop-file"),
            Property("shuffle", MPV_FORMAT_FLAG),
            Property("sid", MPV_FORMAT_INT64),
            Property("aid", MPV_FORMAT_INT64),
            Property("hwdec", MPV_FORMAT_STRING),
        )

        for ((name, format) in p)
            MPVLib.observeProperty(name, format)
    }

    fun addObserver(o: MPVLib.EventObserver) {
        MPVLib.addObserver(o)
    }

    fun removeObserver(o: MPVLib.EventObserver) {
        MPVLib.removeObserver(o)
    }

    private var filePath: String? = null

    // Property getters/setters

    fun Pause() = MPVLib.setPropertyBoolean("pause", true)
    fun Play() = MPVLib.setPropertyBoolean("pause", false)

    var timePos: Int?
        get() = MPVLib.getPropertyInt("time-pos")
        set(progress) = MPVLib.setPropertyInt("time-pos", progress!!)

    var playbackSpeed: Double?
        get() = MPVLib.getPropertyDouble("speed")
        set(speed) = MPVLib.setPropertyDouble("speed", speed!!)

    // Commands

    fun cyclePause() = MPVLib.command(arrayOf("cycle", "pause"))
    fun cycleAudio() = MPVLib.command(arrayOf("cycle", "audio"))
    fun cycleSub() = MPVLib.command(arrayOf("cycle", "sub"))
    fun cycleHwdec() = MPVLib.command(arrayOf("cycle-values", "hwdec", "auto", "mediacodec-copy", "no"))

    fun cycleSpeed() {
        val speeds = arrayOf(0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)
        val currentSpeed = playbackSpeed ?: 1.0
        val index = speeds.indexOfFirst { it > currentSpeed }
        playbackSpeed = speeds[if (index == -1) 0 else index]
    }

    // Surface callbacks

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        MPVLib.setPropertyString("android-surface-size", "${width}x$height")
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        Log.w(TAG, "attaching surface")
        MPVLib.attachSurface(holder.surface)
        // This forces mpv to render subs/osd/whatever into our surface even if it would ordinarily not
        MPVLib.setOptionString("force-window", "yes")

        if (filePath != null) {
            MPVLib.command(arrayOf("loadfile", filePath as String))
            filePath = null
        } else {
            // We disable video output when the context disappears, enable it back
            MPVLib.setPropertyString("vo", "gpu")
        }
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        Log.w(TAG, "detaching surface")
        MPVLib.setPropertyString("vo", "null")
        MPVLib.setOptionString("force-window", "no")
        MPVLib.detachSurface()
    }

    companion object {
        private const val TAG = "mpv"
    }
}
