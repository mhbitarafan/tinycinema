package com.example.tinycinema.mpv

import android.content.Context
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class MpvPlayerFactory(val dartExecutor: DartExecutor) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return MpvPlayer(context as Context, creationParams, dartExecutor)
    }
}
