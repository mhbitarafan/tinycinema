-keep class is.xyz.mpv** { *; }
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}