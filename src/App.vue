<template>
    <div id="app">
        <div class="appBox">
            <TitleBar></TitleBar>
            <div class="content">
                <!-- <div class="left_chat_list">
                    <LeftMenu></LeftMenu>
                </div> -->
                <div class="right_chat_content">
                    <!-- <RightBar></RightBar> -->
                    <router-view v-if="isRouterAlive"></router-view>
                </div>
            </div>
        </div>
    </div>
</template>
<script>
// @ is an alias to /src
import "./utils/setUp.js";
import TitleBar from "@/components/TitleBar/TitleBar.vue";
// import LeftMenu from "@/components/LeftMenu/LeftMenu.vue";
// import RightBar from "@/components/RightBar/RightBar.vue";
export default {
    name: "app",
    components: {
        TitleBar,
        // LeftMenu,
        // RightBar,
    },
    provide() {
        return {
            reload: this.reload,
        };
    },
    data() {
        return {
            isRouterAlive: true,
            mockMap: {
                pluginIos: "pluginH5",
                pluginAndroid: "pluginH5",
                pluginH5: "pluginH5",
            },
        };
    },
    beforeCreate() {},
    created() {
        // this.initRouter();
        this.initStore()
    },
    methods: {
        reload() {
            this.isRouterAlive = false;
            this.$nextTick(() => {
                setTimeout(() => {
                    this.isRouterAlive = true;
                }, 0);
            });
        },
        initRouter() {
            this.$router.push({
                name: this.mockMap[process.env.CURRENT_PRO],
            });
        },
        initStore(){
            this.$store.commit("setLocalUrl", '');
            this.$store.commit("changeRun", false);
        }
    },
};
</script>
<style lang="less">
html,
body,
div {
    margin: 0;
    padding: 0;
    user-select: none;
}
#app {
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    height: 100vh;
    box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.2);
    .appBox {
        height: 100%;
        .content {
            width: 100%;
            height: calc(~"100% - 52px");
            display: flex;
            .left_chat_list {
                width: 240px;
                height: 100%;
                border-right: 1px solid #e5e5e5;
            }
            .right_chat_content {
                height: 100%;
                flex: 1;
                background: #ffffff;
                overflow: hidden;
                position: relative;
            }
        }
    }
}
#nav {
    padding: 30px;

    a {
        font-weight: bold;
        color: #2c3e50;

        &.router-link-exact-active {
            color: #42b983;
        }
    }
}
.el-message {
    min-width: 200px !important;
    text-align: center;
    p {
        overflow-wrap: anywhere;
    }
}
// /*定义滚动条高宽及背景 高宽分别对应横竖滚动条的尺寸*/
//   ::-webkit-scrollbar{
//     width: 7px;
//     height: 7px;
//     background-color: #F5F5F5;
//   }

//   /*定义滚动条轨道 内阴影+圆角*/
//   ::-webkit-scrollbar-track {
//     box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
//     -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, 0.3);
//     border-radius: 10px;
//     background-color: #F5F5F5;
//   }

//   /*定义滑块 内阴影+圆角*/
//   ::-webkit-scrollbar-thumb{
//     border-radius: 10px;
//     box-shadow: inset 0 0 6px rgba(0, 0, 0, .1);
//     -webkit-box-shadow: inset 0 0 6px rgba(0, 0, 0, .1);
//     background-color: #c8c8c8;
//   }

::-webkit-scrollbar {
    /*滚动条整体样式*/
    width: 10px; /*高宽分别对应横竖滚动条的尺寸*/
    height: 1px;
}
::-webkit-scrollbar-thumb {
    /*滚动条里面小方块*/
    border-radius: 10px;
    box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.2);
    background: #c8c8c8;
}
::-webkit-scrollbar-track {
    /*滚动条里面轨道*/
    box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.2);
    border-radius: 10px;
    background: #ededed;
}
</style>
