<template>
  <div class="hello">
{{ mot }} 
    <p>
    <canvas v-bind:id=mot 
      v-bind:width=width v-bind:height=height 
      v-on:click="click" 
      v-on:mousemove=over
      v-on:mouseleave=mouseLeft
      
      ></canvas>
    </p>
  </div>
</template>

<script>
export default {
  name: 'cav',
  props: {
    mot: String,
    mouseXpos: Number
  },
  data:function () {
    return {
      vueCanvas:1,
      vuec:1,
      width:800,
      height:300,
      points:[],
      critDist:10,
        
      //mouseXpos:-1,

    }
  },
  mounted() {
    var c = document.getElementById(this.mot);
    this.vuec = c;
    var ctx = c.getContext("2d");    
    this.vueCanvas = ctx;

    console.log("this.vueCanvas",this.vueCanvas)
    this.redrawCV()
  },
  watch:{
    'mouseXpos': function (){
        this.redrawCV();
    }
  },
  methods:{
      mouseLeft:function(){
        //this.mouseXpos=-1;
        this.$emit("updatedMouse",-1);
        this.redrawCV();
      },
      over: function(event){
        let rect = this.vuec.getBoundingClientRect(); 
        let x = event.clientX - rect.left; 

        this.$emit("updatedMouse",x);
        
        this.redrawCV();
        

        
      },
      click: function (event) {
        let rect = this.vuec.getBoundingClientRect(); 
        let x = event.clientX - rect.left; 
        let y = event.clientY - rect.top; 
        console.log("x y "+x+ " "+y);

        let lowid = this.dist(x,y)
        if(lowid>=0){
            this.points.splice(lowid,1);
            this.redrawCV()
        }else{
            this.addPoint(x,y)
            this.redrawCV()
        }
        let pnorms = this.points.map((point)=>{return {x:point.x/this.width,y:(point.y-this.height/2)/(this.height/2)}}); 
        this.$emit("updated",{p:pnorms,mot:this.mot});
        return {x:x,y:y}

      },

      dist : function(cx,cy){
        // calc dist
        var distsq = this.points.map( (point,pointidx)=> {
            let d = Math.pow(cx-point.x,2)+Math.pow(cy-point.y,2);
            return {d:d,pid:pointidx};
        });
        
        //console.log("distsq"+distsq);
        var lowest = Number.POSITIVE_INFINITY;
        var lowestid = 0;
        
        var highest = Number.NEGATIVE_INFINITY;
        var highestid = 0;

        var tmp;
        for (var i=distsq.length-1; i>=0; i--) {
            tmp = distsq[i].d;
            if (tmp < lowest) {lowest = tmp; lowestid=distsq[i].pid}
            if (tmp > highest) {highest = tmp; highestid=distsq[i].pid}
        }
        console.log("lowest "+lowestid+" at "+lowest);
        console.log("hiest "+highestid+" at "+highest);

        if(lowest < Math.pow(this.critDist,2)){
            return lowestid
        }else{
            return -1
        }
      },

      addPoint : function (x,y){
        this.points.push({x:x,y:y})

        this.points.sort((a, b) => (a.x > b.x) ? 1 : -1)
      },

      drawPoint:function(x,y){
        this.vueCanvas.strokeStyle = 'black';
        this.vueCanvas.beginPath();
        this.vueCanvas.arc(x, y, this.critDist, 0, 2 * Math.PI);
        this.vueCanvas.stroke();
        
      },
      redrawCV: function(){
        //background
        this.vueCanvas.fillStyle = 'gray';
        this.vueCanvas.fillRect(0, 0, 800, 300);

        this.vueCanvas.strokeStyle = 'red';
        this.vueCanvas.beginPath();
        this.vueCanvas.moveTo(0, this.height/2);    // Move the pen to (30, 50)
        this.vueCanvas.lineTo(this.width, this.height/2);  // Draw a line to (150, 100)
        this.vueCanvas.stroke();          // Render the path
        
        for (let i=0; i<this.width; i+=100) {
          this.vueCanvas.beginPath();
          this.vueCanvas.setLineDash([20, 20]);
          this.vueCanvas.moveTo(i, 0);    // Move the pen to (30, 50)
          this.vueCanvas.lineTo(i, this.height);  // Draw a line to (150, 100)
          this.vueCanvas.stroke();          // Render the path
        
        } 
        this.vueCanvas.setLineDash([]);

        // front 
        this.points.forEach(point => {
            this.drawPoint(point.x,point.y)
        })
        
        if(this.points.length>=2){
            for (var i=0; i<this.points.length-1; i++) {
                this.vueCanvas.strokeStyle = 'green';
                this.vueCanvas.beginPath();
                this.vueCanvas.moveTo(this.points[i].x, this.points[i].y);

                this.vueCanvas.lineTo(this.points[i+1].x, this.points[i+1].y);
                this.vueCanvas.stroke();          // Render the path
            }
        }
        
        if(this.mouseXpos>=0){
            this.vueCanvas.strokeStyle = 'blue';
            this.vueCanvas.beginPath();
            this.vueCanvas.moveTo(this.mouseXpos, 0);    // 
            this.vueCanvas.lineTo(this.mouseXpos,this.height);  // 
            this.vueCanvas.stroke();          // Render the path
        }
      }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
