<template>
    <iframe :src="sinosun" frameborder="0" style="width: 100%; height: 100%;"></iframe>
    <!-- <div class="box">
        <div class="rightContent" v-append="newSinosun" @appended="appended"></div>
    </div> -->
</template>

<script>
const path = require('path')
const ProSinosun = path.join(__dirname, './sinosun-ui/index.html')
export default {
    data() {
        return {
            sinosun: '',
            newSinosun: '',
            DevSinosun: './public/sinosun-ui/index.html',
        }
    },
    created() {
        let num = __dirname.indexOf('node_modules')
        let devSrc = __dirname.slice(0, num - 1)
        this.DevSinosun = path.join(devSrc, this.DevSinosun)
        this.sinosun = process.env.NODE_ENV === 'development' ? this.DevSinosun : ProSinosun
    },
    methods: {
        appended() {
            console.log('end')
        },
    },
}
</script>

<style>
.rightContent {
    width: 100%;
    height: 100%;
}
</style>