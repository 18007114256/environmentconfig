import Vue from "vue";
import VueRouter from "vue-router";
// import Home from '../views/Home.vue'
const { ipcRenderer: ipc } = window.require("electron");

VueRouter.prototype.goBack = function (num) {
    this.isBack = true;
    window.history.go(num || -1);
};
Vue.use(VueRouter);

const routes = [
    {
        path: "/",
        // name: 'home',
        // component: Home,
        redirect: "/pluginH5",
    },
    {
        path: "/attendance",
        name: "attendance",
        component: () => import(/* webpackChunkName: "about" */ "../views/Attendance.vue"),
    },
    {
        path: "/money",
        name: "money",
        component: () => import(/* webpackChunkName: "about" */ "../views/Money.vue"),
    },
    {
        path: "/sinosun",
        name: "sinosun",
        component: () => import(/* webpackChunkName: "about" */ "../views/Sinosun.vue"),
    },
    {
        path: "/about",
        name: "about",
        component: () => import(/* webpackChunkName: "about" */ "../views/About.vue"),
    },
    {
        path: "/tar",
        name: "tar",
        component: () => import(/* webpackChunkName: "about" */ "../views/Tar.vue"),
    },
    {
        path: "/library",
        name: "library",
        component: () => import(/* webpackChunkName: "about" */ "../views/Library.vue"),
    },
    {
        path: "/test",
        name: "test",
        component: () => import(/* webpackChunkName: "about" */ "../views/test.vue"),
    },
    {
        path: "/pluginHome",
        name: "pluginHome",
        component: () =>
            import(/* webpackChunkName: "about" */ "../components/PluginComponents/home.vue"),
    },
    {
        path: "/pluginH5",
        name: "pluginH5",
        component: () => import(/* webpackChunkName: "about" */ "../components/PluginComponents/pluginMgr.vue"),
    },
    {
        path: "/pluginScpmock",
        name: "pluginScpmock",
        component: () =>
            import(/* webpackChunkName: "about" */ "../components/PluginComponents/scpMock.vue"),
    },
    {
        path: "/pluginAndroid",
        name: "pluginAndroid",
        component: () =>
            import(/* webpackChunkName: "about" */ "../components/PluginComponents/android.vue"),
    },
    {
        path: "/pluginIos",
        name: "pluginIos",
        component: () =>
            import(/* webpackChunkName: "about" */ "../components/PluginComponents/ios.vue"),
    },
    {
        path: "/projectDetail",
        name: "projectDetail",
        component: () =>
            import(/* webpackChunkName: "about" */ "../components/PluginComponents/projectDetail.vue"),
    },
];
let pluginMap = {
    pluginHome: "pluginHome",
    plugin: "pluginHome",
    pluginScpMock: "pluginHome",
    pluginAndroid: "pluginHome",
    pluginIos: "pluginHome",
};
const router = new VueRouter({
    routes,
});
router.beforeEach((to, from, next) => {
    // to: Route: 即将要进入的目标 路由对象
    // from: Route: 当前导航正要离开的路由
    // next: Function: 一定要调用该方法来 resolve 这个钩子。执行效果依赖 next 方法的调用参数。
    let name = pluginMap[to.name] ? pluginMap[to.name] : to.name;
    ipc.send("routerIn", name);
    next();
});
const originalPush = VueRouter.prototype.push;
VueRouter.prototype.push = function push(location) {
    return originalPush.call(this, location).catch((err) => err);
};
export default router;
