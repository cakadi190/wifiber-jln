# ========= Flutter Core =========
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# ========= Kotlin / Coroutines =========
-keepclassmembers class kotlin.Metadata { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ========= Android Components =========
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# ========= Views =========
-keep class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ========= Serialization =========
-keep class com.google.gson.** { *; }
-keep class com.fasterxml.jackson.** { *; }
-keepattributes Signature, *Annotation*

# ========= Networking =========
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# ========= Native / JNI =========
-keepclasseswithmembernames class * {
    native <methods>;
}

# ========= Strip Unused =========
-dontnote
-dontwarn
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-dontpreverify
