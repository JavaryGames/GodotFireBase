package org.godotengine.godot;

import android.app.Activity;
import android.content.Context;

import com.crashlytics.android.Crashlytics;
import com.crashlytics.android.ndk.CrashlyticsNdk;
import io.fabric.sdk.android.Fabric;

import com.google.firebase.FirebaseApp;

public class Crash {

    public static Crash getInstance (Activity p_activity) {
		if (mInstance == null) {
			synchronized (Crash.class) {
				mInstance = new Crash(p_activity);
			}
		}

		return mInstance;
	}

	public Crash(Activity p_activity) {
		activity = p_activity;
	}

	public void init (FirebaseApp firebaseApp) {
		final Fabric fabric = new Fabric.Builder(activity)
                .kits(new Crashlytics(), new CrashlyticsNdk())
                .build();
		Fabric.with(fabric);

		if (userId != null) {
			Crashlytics.setUserIdentifier(userId);
		}

		mFirebaseApp = firebaseApp;
	}

	public void crash() {
		if (!isInitialized()) return;
		Crashlytics.getInstance().crash();
	}

	public void log(final String message) {
		if (!isInitialized()) return;
		Crashlytics.log(message);
	}

	public void setString(String key, String value) {
		if (!isInitialized()) return;
		Crashlytics.setString(key, value);
	}

	public void setBool(String key, boolean value) {
		if (!isInitialized()) return;
		Crashlytics.setBool(key, value);
	}

	public void setReal(String key, float value) {
		if (!isInitialized()) return;
		Crashlytics.setDouble(key, value);
	}

	public void setInt(String key, int value) {
		if (!isInitialized()) return;
		Crashlytics.setInt(key, value);
	}

	public void setUserId(String id) {
		if (!isInitialized()) {
			userId = id;
		} else {
			Crashlytics.setUserIdentifier(id);
		}
	}

	public void logException(String message) {
		if (!isInitialized()) return;
		Crashlytics.logException(new Exception(message));
	}

	public void logWarning(String message) {
		if (!isInitialized()) return;
		Crashlytics.logException(new CrashlyticsWarningException(message));
	}

	public void logError(String message) {
		if (!isInitialized()) return;
		Crashlytics.logException(new CrashlyticsErrorException(message));
	}

	private boolean isInitialized() {
		return mFirebaseApp != null;
	}

    private static Context context;
	private static Activity activity;

	private FirebaseApp mFirebaseApp = null;

	private static Crash mInstance = null;

	private String userId = null;
}

class CrashlyticsWarningException extends Exception {
	CrashlyticsWarningException(String message) {
		super(message);
	}

}

class CrashlyticsErrorException extends Exception {
	CrashlyticsErrorException(String message) {
		super(message);
	}
}