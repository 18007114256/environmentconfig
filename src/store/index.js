import Vue from "vue";
import Vuex from "vuex";
import createPersistedState from "vuex-persistedstate";

Vue.use(Vuex);

export default new Vuex.Store({
    state: {
        pluginType: "pluginH5",
        running: false,
        localChromeUrl: "",
    },
    mutations: {
        changeType(state, payload) {
            state.pluginType = payload;
        },
        changeRun(state, payload) {
            state.running = payload;
        },
        setLocalUrl(state, payload) {
            state.localChromeUrl = payload;
        },
    },
    actions: {},
    modules: {},
    plugins: [createPersistedState()],
});
