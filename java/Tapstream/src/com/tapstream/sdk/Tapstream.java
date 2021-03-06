package com.tapstream.sdk;

import com.tapstream.sdk.Hit.CompletionHandler;

import android.content.Context;

public class Tapstream implements Api {
	private static Tapstream instance;

	public static void create(Context context, String accountName, String developerSecret) {
		create(context, accountName, developerSecret, null);
	}

	public static void create(Context context, String accountName, String developerSecret, String hardware) {
		synchronized (Tapstream.class) {
			if (instance == null) {
				instance = new Tapstream(context, accountName, developerSecret, hardware);
			} else {
				Logging.log(Logging.WARN, "Tapstream Warning: Tapstream already instantiated, it cannot be re-created.");
			}
		}
	}

	public static Tapstream getInstance() {
		synchronized (Tapstream.class) {
			if (instance == null) {
				throw new RuntimeException("You must first call Tapstream.create");
			}
			return instance;
		}
	}

	private class DelegateImpl implements Delegate {
		public int getDelay() {
			return core.getDelay();
		}

		public boolean isRetryAllowed() {
			return true;
		}
	}

	private Delegate delegate;
	private Platform platform;
	private CoreListener listener;
	private Core core;

	private Tapstream(Context context, String accountName, String developerSecret, String hardware) {
		delegate = new DelegateImpl();
		platform = new PlatformImpl(context);
		listener = new CoreListenerImpl();
		core = new Core(delegate, platform, listener, accountName, developerSecret, hardware);
	}

	public void fireEvent(Event e) {
		core.fireEvent(e);
	}

	public void fireHit(Hit h, CompletionHandler completion) {
		core.fireHit(h, completion);
	}
}
