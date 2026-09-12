# flutter_local_notifications schedules through classes that are only
# referenced reflectively, so R8 must not strip or rename them.
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }

# Gson is used by flutter_local_notifications to persist scheduled alarms.
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.gson.**
-keep class com.google.gson.** { *; }
