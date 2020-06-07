<template>
  <div id="app">
  <button v-on:click="download">down !</button>
  <button v-on:click="testbtn" :disabled=!buttonEnable>test</button>
    <cav mot="hipL"  v-bind:mouseXpos="mouseXpos"  v-on:updated="gup" v-on:updatedMouse="updatedMouse" />
    <cav mot="hipR"  v-bind:mouseXpos="mouseXpos"  v-on:updated="gup" v-on:updatedMouse="updatedMouse"/>
    <cav mot="feetL" v-bind:mouseXpos="mouseXpos"   v-on:updated="gup" v-on:updatedMouse="updatedMouse"/>
    <cav mot="feetR" v-bind:mouseXpos="mouseXpos"   v-on:updated="gup" v-on:updatedMouse="updatedMouse"/>
  </div>
</template>

<script>
//import HelloWorld from './components/HelloWorld.vue'
import cav from './components/cav.vue'
import axios from 'axios';

export default {
  name: 'App',
  data:function () {
    return {
      ps:{},
      txt:"",
      mouseXpos:-1,

      buttonEnable:true,
    }
  },
  components: {
    //HelloWorld,
    cav
  },
  methods:{
      updatedMouse: function (event) {
        this.mouseXpos = event
      },
      gup: function (event) {

        this.ps[event.mot] = event.p

        this.txt = JSON.stringify(this.ps)
    
      },
      testbtn:function(){
        this.buttonEnable = false;
        axios.post("http://192.168.1.58:8000/seq",{ crossdomain: true,body:this.txt },)
          .then(() => {
          // JSON responses are automatically parsed.
          //console.log(response)
          this.buttonEnable = true;
        })
      },
      download:function(){
		const url = window.URL.createObjectURL(new Blob([this.txt]))
        const link = document.createElement('a')
        link.href = url
        link.setAttribute('download', 'file.json') //or any other extension
        document.body.appendChild(link)
        link.click()
      }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
