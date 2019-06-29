
var test = d3.json("data.json",function(data){
    var div = d3.select("body").append("div").attr("class","tooltip").style("opacity",0);
    var finalDict ={}
    var nodes =[]
    defaultColor = "#00FF00";

    var canvas = d3.select("body").append("svg")
        .attr("width",250)
        .attr("height",550)
        .style("background-color", 'black')

    var canvas = d3.select("body").append("svg")
        .attr("width",1250)
        .attr("height",550)
        .style("background-color", 'black')
        .style("text-align","center")
    
    for(i=0;i<data.nodes.length; i++){
        var temp = {
            x:data.nodes[i].x,
            y:data.nodes[i].y,
            neighbourNodes:[],
            OverAllAmount:0
            }
        nodes.push(data.nodes[i].id)
        finalDict[data.nodes[i].id]=temp;
    }
    max = 0
    linkMax = 0
    for(i=0;i<data.links.length;i++){
        t = [data.links[i].node01,data.links[i].node02]
        for(j =0; j<t.length;j++){
            var temp = finalDict[t[j]]
            var tempNeighbour = temp.neighbourNodes
            var nodeLink = data.links[i].node02
            if(j==1){
                nodeLink =  data.links[i].node01
            }
            tempNeighbour.push({
                node:nodeLink,
                amount:data.links[i].amount
            })
            temp.neighbourNodes = tempNeighbour
            temp.OverAllAmount +=  data.links[i].amount
            if(temp.OverAllAmount > max){
                max = temp.OverAllAmount
            }
            if(data.links[i].amount > linkMax ){
                linkMax = data.links[i].amount 
            }
            finalDict[t[j]] = temp
        }
        
    }

    var rScale = d3.scaleLinear()
    .domain([0,max+1])
    .range([0,nodes.length*2])

    var lScale = d3.scaleLinear()
    .domain([0,linkMax+1])
    .range([0,nodes.length])

    lines = {}
    for(i=0;i<nodes.length;i++){
        initialNode = finalDict[nodes[i]]
        tempLines = {}
        for(j=0;j<initialNode.neighbourNodes.length;j++){
            finalNode = initialNode.neighbourNodes[j]
            tempLines[finalNode.node]=canvas.append("line")
            .attr("x1",initialNode.x)
            .attr("y1",initialNode.y)
            .attr("x2",finalDict[finalNode.node].x)
            .attr("y2",finalDict[finalNode.node].y)
            .attr("stroke",defaultColor)
            .style("opacity",0.8)
            .attr("stroke-width",lScale(finalNode.amount))
        }
        lines[nodes[i]] = tempLines
    }
    var circles = {}
    for(i=0;i<nodes.length;i++){
        col = finalDict[nodes[i]].col
        circles[nodes[i]] = canvas.append("circle")
        .attr("cx", finalDict[nodes[i]].x)
        .attr("cy", finalDict[nodes[i]].y)
        .attr("r", rScale(finalDict[nodes[i]].OverAllAmount))
        .attr("fill","blue")
        .attr("stroke-width", rScale(finalDict[nodes[i]].OverAllAmount)/2)
        .attr("stroke",defaultColor)
        .on("mouseover",mouseoverfunc)
        .on("mouseout",mouseoutfunc)
    }

    function isPresent(node,checkList){
        for(k=0;k<checkList.length;k++){
            if(checkList[k] == node){
                return true;
            }
        }
        return false;
    }
    function mouseoutfunc(d){
        for(i=0;i<nodes.length;i++){
            circles[nodes[i]].attr("stroke",defaultColor)
                .style("opacity",1)
            for (var key in lines[nodes[i]]) {
                    lines[nodes[i]][key].attr("stroke",defaultColor)
                    .style("opacity",0.8)
                }
        }
        div.transition().duration(200).style("opacity",0);
    }

    function mouseoverfunc(d) {
        x = d3.select(this).attr("cx");
        y = d3.select(this).attr("cy");
        node = 0
        for(i=0;i<nodes.length;i++){
            if( finalDict[nodes[i]].x == x && finalDict[nodes[i]].y == y ){
                node = nodes[i]
            }
        }
        neighBourNodesList = []
        for(i=0;i<finalDict[node].neighbourNodes.length;i++){
            neighBourNodesList.push(finalDict[node].neighbourNodes[i].node)
        }
        for(i=0;i<nodes.length;i++){
            if(nodes[i] == node){
                circles[node].attr("stroke","red")
                .style("opacity",1)   
            }
            else if(isPresent(nodes[i],neighBourNodesList)){
                circles[nodes[i]].attr("stroke","yellow")
                .style("opacity",0.6)
            }
            else{
                circles[nodes[i]].attr("stroke",defaultColor)
                .style("opacity",0.2)
            }
            if(nodes[i] == node){
                for (var key in lines[node]) {
                    lines[nodes[i]][key].attr("stroke",defaultColor)
                    .style("opacity",1)
                }
            }
            else {
                for (var key in lines[nodes[i]]) {
                    lines[nodes[i]][key].attr("stroke",defaultColor)
                    .style("opacity",0)
                }
            }

        }
        
        div.transition().duration(200).style("opacity",.9);
        div.html("Site: "+node+"<br>Total Trading Amount: "+finalDict[node].OverAllAmount+"<br>Total Connections: "+finalDict[node].neighbourNodes.length)
        .style("left",x+"px")
        .style("top",y+"px")
    }
})
    
    


