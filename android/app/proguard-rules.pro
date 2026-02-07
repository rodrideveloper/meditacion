# Flutter / Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# flutter_local_notifications — GSON
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# just_audio
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# SharedPreferences
-keep class androidx.datastore.** { *; }

# Nuestros receivers nativos
-keep class com.rodrigorodriguez.meditationtimer.AlarmReceiver { *; }
-keep class com.rodrigorodriguez.meditationtimer.AlarmDismissReceiver { *; }
-keep class com.rodrigorodriguez.meditationtimer.BootReceiver { *; }
-keep class com.rodrigorodriguez.meditationtimer.AlarmScheduler { *; }

# Evitar warnings comunes
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**

# Google Play Core (referenced by Flutter engine for deferred components)
-dontwarn com.google.android.play.core.**
