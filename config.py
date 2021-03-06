
import sys
import json
import os
import re
import shutil

from colors import *

from app_config import p_config, p_app_id

FILES_LIST		= \
{
"AdMob"		: ["AdMob.java"],
"Analytics"	: ["Analytics.java"],
"Auth"		: ["AnonymousAuth.java", "Auth.java", "EmailAndPassword.java"],
"Base"		: ["Config.java", "FireBase.java", "Utils.java", "AndroidPermissionsChunk.xml"],
"Invites"	: ["Invites.java"],
"Notification"	: ["MessagingService.java", "Notification.java", \
                   "NotifyInTime.java", "InstanceIDService.java"],
"RemoteConfig"	: ["RemoteConfig.java"],
"Storage"	: ["storage/"],
"Firestore"	: ["Firestore.java"],
"Crashlytics" : ["Crash.java"],

"AuthGoogle"    : ["GoogleSignIn.java"],
"AuthFacebook"  : ["FacebookSignIn.java"],
"AuthTwitter"   : ["TwitterSignIn.java"],
}

directory = "android"
empty_line = re.compile(r'^\s*$')

def can_build(plat):
    if plat == "android":
        return update_module()
    elif plat == "iphone":
        return True
    else:
        return False

def copytree(src, dst, symlinks=False, ignore=None):
    for item in os.listdir(src):
        if not os.path.exists(dst): os.makedirs(dst)

        s = os.path.join(src, item)
        d = os.path.join(dst, item)

        if os.path.isdir(s): shutil.copytree(s, d, symlinks, ignore)
        else: shutil.copyfile(s, d)
    pass

def parse_file_data(file_data, regex_list, file_type = "Java"):
    final_data = [];

    for rr in regex_list:
        re_start = rr[0]
        re_stop = rr[1]

        # print("Using Regex: " + re_start);

        skip_line = False
        blank_line = False;

        for line in file_data:
            if re_start.search(line) and not skip_line:
                skip_line = True
                continue
            elif re_stop.search(line) and skip_line:
                skip_line = False
                continue
            elif empty_line.match(line):
                blank_line = True;
                continue

            if blank_line and len(final_data) > 0:
                if final_data[-1] != "\n": final_data.append("\n");
                blank_line = False;

            if not skip_line: final_data.append(line);

        file_data = final_data;
        final_data = []

    return file_data;
    pass

def parse_java_file(p_file_src, p_file_dst, p_regex_list):
    p_file_data = []

    try:
        with open(p_file_src, 'r') as file_in:
            p_file_data = file_in.readlines()
    except (OSError, IOError): return res

    out_file = open(p_file_dst, 'w')
    p_file_data = parse_file_data(p_file_data, p_regex_list, "JAVA")
    out_file.write("".join(p_file_data))
    out_file.close()
    pass

def update_module():
    src_dir = os.path.dirname(os.path.abspath(__file__)) + "/android_src/"
    target_dir = os.path.dirname(os.path.abspath(__file__)) + "/android/"

    if os.path.exists(target_dir):
        shutil.rmtree(target_dir)

    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    p_config["Auth"] = p_config["Authentication"]

    if (p_config["Storage"] or p_config["Firestore"]) and not p_config["Auth"]:
        sys.stdout.write(RED)
        print("Storage/Firestore needs FireBase Authentication, Skipping `GodotFireBase` module")
        sys.stdout.write(RESET)

        return False

    data_to_check = \
    ["Analytics", "AdMob", "Auth", "Invites", "Notification", "RemoteConfig",\
    "Storage", "Firestore", "Crashlytics", "AuthFacebook", "AuthGoogle", "AuthTwitter"]

    regex_list = []

    for _file in FILES_LIST["Base"]: shutil.copyfile(src_dir+_file, target_dir+_file)

    if not p_config["Auth"]:
        p_config["AuthGoogle"] = False
        p_config["AuthFacebook"] = False
        p_config["AuthTwitter"] = False

    dbg_msg = ""
    for d in data_to_check:
        if not p_config[d]:
            regex_list.append(\
            [re.compile(r'([\/]+'+d+'[\+]+)'), re.compile(r'([\/]+'+d+'[\-]+)')])
        else:
            dbg_msg += " %s," % d

            if d != "Storage":
                if d == "Auth":
                    if not os.path.exists(target_dir+"auth/"): os.makedirs(target_dir+"auth/")
                for files in FILES_LIST[d]:
                    if d == "Auth" or (d.startswith("Auth")):
                        shutil.copyfile(src_dir+"auth/"+files, target_dir+"auth/"+files)
                    else: shutil.copyfile(src_dir+files, target_dir+files)
            else: copytree(src_dir+d.lower(), target_dir+d.lower())

    print(GREEN + "FireBase: " + RESET + "[" + dbg_msg[1:-1] + "]")

    # Copy FireBase.java file into memory
    parse_java_file(src_dir+"FireBase.java", target_dir+"FireBase.java", regex_list)

    if p_config["Auth"] and (not p_config["AuthGoogle"] or not p_config["AuthFacebook"] or not p_config["AuthTwitter"]):
        parse_java_file(src_dir+"auth/Auth.java", target_dir+"auth/Auth.java", regex_list)

    # Parsing AndroidManifest
    regex_list = []

    for d in data_to_check:
        if not p_config[d]:
            regex_list.append(\
            [re.compile(r'(<\![\-]+ '+d+' [\-]+>)'), re.compile(r'(<\![\-]+ '+d+' [\-]+>)')])

    out_file = open(target_dir+"AndroidManifestChunk.xml", 'w')
    file_data = []

    try:
        with open(src_dir+"AndroidManifestChunk.xml", 'r') as file_in:
            file_data = file_in.readlines()
    except (OSError, IOError): return res

    file_data = parse_file_data(file_data, regex_list, "XML")

    out_file.write("".join(file_data))
    out_file.close()

    return True

def configure(env):
    if env["platform"] == "android":
        env.android_add_maven_repository("url 'https://maven.fabric.io/public'")
        env.android_add_maven_repository("url 'https://maven.google.com'")
        env.android_add_maven_repository(\
        "url 'https://oss.sonatype.org/content/repositories/snapshots'")

        env.android_add_gradle_classpath("com.google.gms:google-services:4.1.0")
        env.android_add_gradle_plugin("com.google.gms.google-services")

        env.android_add_dependency("compile 'com.android.support:support-annotations:25.0.1'")
        env.android_add_dependency("compile 'com.google.firebase:firebase-core:16.0.3'")
        env.android_add_dependency("compile 'com.google.firebase:firebase-analytics:16.0.1'")
        env.android_add_dependency("compile 'com.google.android.gms:play-services-measurement-base:16.0.0'")
        env.android_add_dependency("implementation 'com.android.support:support-v4:28.0.0'")
        env.android_add_dependency("compile group: 'org.jvnet.sorcerer', name: 'sorcerer-javac', version: '0.8'")

        if p_config["Auth"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-auth:16.0.3'")
            if p_config["AuthGoogle"]:
                env.android_add_dependency("compile 'com.google.android.gms:play-services-auth:16.0.0'")

            if p_config["AuthFacebook"]:
                env.android_add_dependency("compile 'com.facebook.android:facebook-android-sdk:4.18.0'")

            if p_config["AuthTwitter"]:
                env.android_add_dependency(\
                "compile('com.twitter.sdk.android:twitter-core:1.6.6@aar') { transitive = true }")
                env.android_add_dependency(\
                "compile('com.twitter.sdk.android:twitter:1.13.1@aar') { transitive = true }")

        if p_config["AdMob"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-ads:15.0.1'")

        if p_config["RemoteConfig"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-config:16.0.0'")

        if p_config["Notification"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-messaging:17.3.0'")
            env.android_add_dependency("compile 'com.firebase:firebase-jobdispatcher:0.8.5'")

        if p_config["Invites"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-invites:16.0.3'")

        if p_config["Storage"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-storage:16.0.1'")

        if p_config["Firestore"]:
            env.android_add_dependency("compile 'com.google.firebase:firebase-firestore:17.1.0'")

        if p_config["Crashlytics"]:
            env.android_add_gradle_classpath("io.fabric.tools:gradle:1.28.1")
            env.android_add_dependency("compile 'com.crashlytics.sdk.android:crashlytics:2.9.9'")
            env.android_add_dependency("compile 'com.crashlytics.sdk.android:crashlytics-ndk:2.0.5'")
            env.android_add_gradle_plugin("io.fabric")
            env.android_add_gradle_content("""
crashlytics {
    enableNdk true
    manifestPath 'AndroidManifest.xml'
    androidNdkOut 'libs/debug'
    androidNdkLibsOut 'libs/release'
}
            """)

        if "MediationTapjoy" in p_config and p_config["MediationTapjoy"]:
            env.android_add_dependency("implementation 'com.tapjoy:tapjoy-android-sdk:12.1.0'")
            env.android_add_dependency("implementation 'com.google.ads.mediation:tapjoy:12.1.0.0'")


        env.android_add_dependency("compile 'commons-codec:commons-codec:1.10'")
        env.android_add_dependency("implementation 'com.android.support:multidex:1.0.3'")

        env.android_add_java_dir("android")
        env.android_add_res_dir("res")
        env.android_add_to_manifest("android/AndroidManifestChunk.xml")
        env.android_add_to_permissions("android/AndroidPermissionsChunk.xml")
        env.android_add_default_config("minSdkVersion 15")
        env.android_add_default_config("applicationId '"+ p_app_id +"'")
        env.android_add_default_config("multiDexEnabled true")

    elif env["platform"] == "iphone":
        env.Append(FRAMEWORKPATH=['ios_src/lib'])
        env.Append(LINKFLAGS=['-ObjC', '-framework','AdSupport', '-framework', 'UserNotifications','-framework','CoreTelephony', '-framework','EventKit', '-framework','EventKitUI', '-framework','MessageUI', '-framework','StoreKit', '-framework','SafariServices', '-framework','CoreBluetooth', '-framework','AssetsLibrary', '-framework','CoreData', '-framework','CoreLocation', '-framework','CoreText', '-framework','ImageIO', '-framework', 'GLKit', '-framework','CoreVideo', '-framework', 'CFNetwork', '-framework', 'MobileCoreServices', '-framework', 'FirebaseAnalytics', '-framework', 'FIRAnalyticsConnector', '-framework', 'FirebaseCoreDiagnostics', '-framework', 'FirebaseCore', '-framework', 'FirebaseInstanceID', '-framework', 'GoogleAppMeasurement', '-framework', 'GoogleUtilities', '-framework', 'nanopb', '-framework', 'GoogleMobileAds'])
