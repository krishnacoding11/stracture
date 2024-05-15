package com.asite.field.pdftron.factories;

import android.content.Context;

import androidx.annotation.NonNull;

import com.asite.field.pdftron.view.PdftronDocumentView;
import java.lang.ref.WeakReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PdftronDocumentViewFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;
    private final WeakReference<Context> mContextRef;

    public PdftronDocumentViewFactory(BinaryMessenger messenger, Context activityContext) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        mContextRef = new WeakReference<>(activityContext);
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int id, Object o) {
        return new PdftronDocumentView(context, mContextRef.get(), this.messenger, id);
    }
}
