package com.example.tinycinema.mpv

import android.content.Context
import android.os.Handler
import android.view.View
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import `is`.xyz.mpv.MPVLib
import `is`.xyz.mpv.Utils

const val MpvChan = "mpv_method_channel"

class MpvPlayer(
        context: Context,
        creationParams: Map<String?, Any?>?,
        dartExecutor: DartExecutor,
) : PlatformView, MPVLib.EventObserver, MethodChannel.MethodCallHandler {
    var mainHandler: Handler = Handler(context.mainLooper)
    val channel: MethodChannel
    val mpvView: MPVView
    private val url = creationParams?.get("url")

    override fun getView(): View {
        return mpvView
    }

    override fun dispose() {
        mpvView.removeObserver(this)
        mpvView.destroy()
    }

    init {
        Utils.copyAssets(context)
        channel = MethodChannel(dartExecutor.binaryMessenger, MpvChan)
        mpvView = MPVView(context)
        mpvView.initialize(context.filesDir.path)
        mpvView.playFile(url as String)
        mpvView.addObserver(this)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "cyclePause" -> {
                mpvView.cyclePause()
            }
            "playUrl" -> {
                mpvView.playFile(call.arguments as String)
            }
            "getTimePos" -> {
                result.success(mpvView.timePos)
            }
            "forward10" -> {
                mpvView.timePos = mpvView.timePos?.plus(10)
                result.success(mpvView.timePos)
            }
            "backward10" -> {
                mpvView.timePos = mpvView.timePos?.minus(10)
            }
            "seek" -> {
                mpvView.timePos = call.arguments as Int
            }
            "cycleSub" -> {
                mpvView.cycleSub()
                result.success("")
            }
            "cycleAudio" -> {
                mpvView.cycleAudio()
                result.success("")
            }
            "cycleSpeed" -> {
                mpvView.cycleSpeed()
                result.success("")
            }
            "cycleHwdec" -> {
                mpvView.cycleHwdec()
                result.success("")
            }
            "pause" -> {
                mpvView.Pause()
            }
            "play" -> {
                mpvView.Play()
            }
        }
    }

    override fun eventProperty(property: String) {}

    override fun eventProperty(property: String, value: Long) {
        mainHandler.post(Runnable { channel.invokeMethod(property, value) })
    }

    override fun eventProperty(property: String, value: Boolean) {
        mainHandler.post(Runnable { channel.invokeMethod(property, value) })
    }

    override fun eventProperty(property: String, value: String) {
        mainHandler.post(Runnable { channel.invokeMethod(property, value) })
    }

    override fun event(eventId: Int) {}
}
