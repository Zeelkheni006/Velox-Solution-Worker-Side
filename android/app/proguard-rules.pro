# Flutter & Firebase
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.exoplayer2.** { *; }

# Multidex support
-keep class androidx.multidex.** { *; }

# Avoid warnings
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Facebook Ads SDK fixes
-keep class com.facebook.infer.annotation.Nullsafe { *; }
-keep class com.facebook.infer.annotation.Nullsafe$Mode { *; }
-dontwarn com.facebook.infer.annotation.Nullsafe
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode

# 🔥 ADD THIS
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
