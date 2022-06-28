package com.example.tinycinema

import com.example.tinycinema.mpv.MpvPlayerFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant.registerWith


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("mpvPlayer", MpvPlayerFactory(flutterEngine.dartExecutor))
        registerWith(flutterEngine);
    }
}
