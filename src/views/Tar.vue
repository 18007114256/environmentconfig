<template>
    <div class="tar">
        <h1>压缩</h1>
    </div>
</template>

<script>
const write = window.require('fs').createWriteStream
const pack = window.require('tar-pack').pack
// const entry = 'C:/Users/86188/Desktop/test1' //tar zip输入文件夹
export default {
    data() {
        return {
            version: '5.0.4.1',
            output: '.',
        }
    },
    mounted() {
        // this.getTar()
    },
    methods: {
        getTar() {
            console.log('process.cwd()',process.cwd())
            pack('C:/Users/86188/Desktop/swp-client/')
                .pipe(write('C:/Users/86188/Desktop/11.tar'))
                .on('error', function (err) {
                    console.error(err.stack)
                })
                .on('close', function () {
                    console.log('done')
                })
        },
    },
}
</script>

<style lang="less">
</style>