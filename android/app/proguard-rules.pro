# Flutter-specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Stripe (or any 3rd party SDKs you're using)
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Prevent obfuscation of model classes
-keep class com.example.lcommerce.model.** { *; }
