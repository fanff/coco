<template>
  <div id="app">
      <h1 v-if="connected">:)</h1>
      <h1 v-else>😢 </h1>
        
      <div class="slidecontainer">
          lol ?
          <input type="range" min="-1" max="1" v-model="sval" step=".1" class="slider" >
          <label>{{sval}} </label>
      </div>
      <button v-on:click="tbtn()">lol</button>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  name: 'App',
  data:function () {
    return {
      connection:false,
      connected:false,
      txt:"",
      mouseXpos:-1,
      sval:0,
      buttonEnable:true,
    }
  },
  components: {
    //HelloWorld,
  },
  methods:{
      updatedMouse: function (event) {
        this.mouseXpos = event
      },
      onmessage:function(){
          console.log("got message !");
        
      },
      onopen:function(){
        this.connected=true;
      },
      tbtn:function(){
          console.log("tbns!");
          this.connection.send("hello coco");
      },
      testbtn:function(){
        this.buttonEnable = false;
        axios.post("http://192.168.1.58:8000/seq",{ crossdomain: true,body:this.txt },)
          .then(() => {
          // JSON responses are automatically parsed.
          //console.log(response)
          this.buttonEnable = true;
        },(error)=>{
          console.log(error); 
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
      },
      sendCommands(){
        if(this.connected){
            this.connection.send(JSON.stringify({a:this.sval}))
        }
      }
  },
  watch:{
    sval:function(){
        this.sendCommands()
    }
  },
  created: function(){
    this.connection = new WebSocket("ws://192.168.1.58:8765");

    this.connection.onmessage = this.onmessage;

    this.connection.onopen = this.onopen;
    this.connection.onclose = function(){
        console.log("close!");
        this.connected=false;
    }

  },

  beforeDestroy: function(){

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
