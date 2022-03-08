import NativeBrige from "./NativeBrige.js";
import IosBrigeImpl from "./IosBrigeImpl.js";
import AndroidBrigeImpl from "./AndroidBrigeImpl.js";

let env = process.env.CURRENT_PRO;
if (env == "pluginIos") {
    NativeBrige.setNativeBrigeImpl(IosBrigeImpl);
} else if (env == "pluginAndroid") {
    NativeBrige.setNativeBrigeImpl(AndroidBrigeImpl);
}

window.NativeBrige = NativeBrige;
