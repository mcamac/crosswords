(function(){$(function(){var e,t,n,r,i,s,o,u,a,f,l,c,h,p,d,v,m,g,y,b,w,E,S,x,T,N,C,k,L,A,O,M,_,D,P,H,B,j,F,I,q,R,U,z,W,X,V,J,K;V=new WebSocket("ws://"+location.hostname+":"+location.port+location.pathname+"/sub");V.onmessage=function(e){var t,n;t=JSON.parse(e.data);if(t.type==="client chat message"){$("#chat_box").append("<p><b>"+t.name+"</b>: "+t.content+"</p>");n=$("#chat_box")[0];n.scrollTop=n.scrollHeight-$(n).height}if(t.type==="room chat message"){$("#chat_box").append("<p><i>"+t.content+"</i></p>")}if(t.type==="new puzzle"){N(t.content)}if(t.type==="existing puzzle"){N(t.content.puzzle);h(t.content.grid);if(t.content.complete){b()}}if(t.type==="change square"){R(t.content.i,t.content.j,t.content.char,false)}if(t.type==="room members"){t.content.sort();$("#members_box").html(t.content.join(", "))}if(t.type==="puzzle finished"){return b()}};F=function(e){return V.send(JSON.stringify({type:"client chat message",content:e}))};b=function(){return r.attr("opacity",.2)};w=[];E=540;L={};A={};O={};H=15;r=null;D={};z=E/(1*H);T={};o=0;u=0;a={A:{},D:{}};U=null;t=null;c=null;f=[];i={};P=Raphael("crossword_canvas",E+2,E+2);e=0;l="A";s=function(e,t){if(i[e][t]){i[e][t].remove()}return i[e][t]=P.rect(t*z+.5,e*z+.5,z,z).attr({fill:"#333"})};S=function(e,t,n){if(e[t][n]==="_"){return false}if(t===0||n===0){return true}if(e[t-1][n]==="_"||e[t][n-1]==="_"){return true}return false};C=function(e,t,n){return P.text((t+.5)*z,(e+.55)*z,n).attr({"font-size":20,"text-anchor":"middle","font-family":"Source Sans","font-			 	weight":"normal"})};h=function(e){var t,n,r,i,s;s=[];for(t=r=0,i=H-1;0<=i?r<=i:r>=i;t=0<=i?++r:--r){s.push(function(){var r,i,s;s=[];for(n=r=0,i=H-1;0<=i?r<=i:r>=i;n=0<=i?++r:--r){if(T[t][n]){T[t][n].remove()}s.push(T[t][n]=C(t,n,e[t][n]))}return s}())}return s};R=function(e,t,n,r){if(T[e][t]){T[e][t].remove()}n=n.toUpperCase();return T[e][t]=P.text((t+.5)*z,(e+.55)*z,n).attr({"font-size":20,"text-anchor":"middle","font-family":"Source Sans","font-							 	weight":"normal"})};I=function(e,t,n){return V.send(JSON.stringify({type:"change square",content:{i:e,j:t,"char":n}}))};X=function(e,t,n){if(t<0||n<0||t>=H||n>=H||e[t][n]==="_"){return false}return true};M=function(e,t){return e>=0&&t>=0&&e<H&&t<H};d=function(e,t,n,r){if(!X(e,t,n)){return-1}if(r==="A"){while(X(e,t,n-1)){n--}}if(r==="D"){while(X(e,t-1,n)){t--}}return A[t][n]};_=function(e){if(e==="D"){return"A"}else{return"D"}};p=function(){l=_(l);B();return W()};k=function(e,t,n,r){var i,s;i=e+n;s=t+r;while(!X(D,i,s)&&M(i,s)){i+=n;s+=r}if(M(i,s)){return[i,s]}return[e,t]};n="abcdefghijklmnopqrstuvwxyz";for(J=0,K=n.length;J<K;J++){x=n[J];key(x,function(e){I(o,u,String.fromCharCode(e.keyCode));if(l==="A"){return g()}else{return v()}})}m=function(){var e;e=k(o,u,0,-1);return q(e[0],e[1])};g=function(){var e;e=k(o,u,0,1);return q(e[0],e[1])};y=function(){var e;e=k(o,u,-1,0);return q(e[0],e[1])};v=function(){var e;e=k(o,u,1,0);return q(e[0],e[1])};key("left",m);key("up",y);key("right",g);key("down",v);key("space",p);key("backspace",function(e){e.preventDefault();I(o,u,"");if(l==="A"){return m()}else{return y()}});B=function(){var e,n,r,i;n=u;e=u;while(X(D,o,n-1)){n--}while(X(D,o,e+1)){e++}t.attr({width:z*(e-n+1),x:n*z+.5,y:o*z+.5,fill:l==="A"?"#4f7ec4":"#ddd"});i=o;r=o;while(X(D,i-1,u)){i--}while(X(D,r+1,u)){r++}c.attr({height:z*(r-i+1),x:u*z+.5,y:i*z+.5,fill:l==="D"?"#4f7ec4":"#ddd"});U.attr({x:u*z+.5,y:o*z+.5});if(T[o][u]){T[o][u].attr("fill","white")}if(A[o][u]){return L[o][u].attr("fill","white")}};q=function(e,t){if(D[e][t]==="_"){return}if(T[o][u]){T[o][u].attr("fill","black")}if(L[o][u]){L[o][u].attr("fill","black")}o=e;u=t;B();return W()};W=function(){var e,t,n;t=d(D,o,u,l);n=d(D,o,u,_(l));$(".li-clue").removeClass("active");$(".li-clue").removeClass("semi-active");$(".li-clue[data-clue-id="+l+t+"]").addClass("active");$(".li-clue[data-clue-id="+_(l)+n+"]").addClass("semi-active");$("#"+l+"_clues").scrollTo(".li-clue[data-clue-id="+l+t+"]",75);$("#"+_(l)+"_clues").scrollTo(".li-clue[data-clue-id="+_(l)+n+"]",75);e=a[l][t];return $("#current_clue").html(""+t+l+" - "+e)};N=function(e){var t,n,i,f,c,h,d,v,m,g,y,b,x,T,N,C,k,M,_,B,F,I,R;m=e;D=m.puzzle;$("#puzzle_title").html(m.title);H=m.height;z=E/(1*H);a["A"]=m.clues.across;a["D"]=m.clues.down;j();M=e.clues.across;for(d in M){t=M[d];$("#A_clues").append("<li class='li-clue' data-clue-id=A"+d+'><div class="num"> '+d+' </div> <div class="clue-text"> '+t+" </div></li>")}_=e.clues.down;for(d in _){t=_[d];$("#D_clues").append("<li class='li-clue' data-clue-id=D"+d+'><div class="num"> '+d+' </div> <div class="clue-text"> '+t+" </div></li>")}$(".li-clue").on("click",function(e){var t,n;t=$(this).data("clue-id");n=O[t];if(t[0]!==l){p()}return q(n[0],n[1])});for(f=y=0,B=H-1;0<=B?y<=B:y>=B;f=0<=B?++y:--y){for(c=b=0,F=H-1;0<=F?b<=F:b>=F;c=0<=F?++b:--b){if(m.puzzle[f][c]==="_"){s(f,c)}}}for(v=x=0;0<=H?x<=H:x>=H;v=0<=H?++x:--x){g=z*v+.5;w.push(P.path("M"+g+",0.5v"+E));w.push(P.path("M0.5,"+g+"h"+E))}for(N=0,T=w.length;N<T;N++){h=w[N];h.attr({stroke:"#ddd","stroke-width":1})}n=1;for(f=C=0,I=H-1;0<=I?C<=I:C>=I;f=0<=I?++C:--C){for(c=k=0,R=H-1;0<=R?k<=R:k>=R;c=0<=R?++k:--k){if(S(D,f,c)){L[f][c]=P.text(z*c+2,z*f+8,n).attr({"text-anchor":"start"});A[f][c]=n;O["A"+n]=[f,c];O["D"+n]=[f,c];n+=1}}}if(r){r.remove()}r=P.rect(0,0,E,E).attr({stroke:"none",fill:"#62cb62",opacity:0});r.click(function(e){var t,n;t=Math.floor(e.layerY/z);n=Math.floor(e.layerX/z);if(t===o&&n===u){p()}return q(t,n)});i=0;while(D[0][i]==="_"){i++}return q(0,i)};$("#chat_input").on("keyup",function(e){if(e.keyCode===13){F($(this).val());return $(this).val("")}});j=function(){var e,n,r,s,o,u,a,f,l,h,p;for(o=0,f=w.length;o<f;o++){r=w[o];r.remove()}for(e in T){s=T[e];l=T[e];for(n in l){s=l[n];if(i[e]&&i[e][n]){i[e][n].remove()}if(T[e]&&T[e][n]){R(e,n,"",false)}if(L[e]&&L[e][n]){L[e][n].remove()}}}for(e=u=0,h=H-1;0<=h?u<=h:u>=h;e=0<=h?++u:--u){i[e]={};T[e]={};A[e]={};L[e]={};for(n=a=0,p=H-1;0<=p?a<=p:a>=p;n=0<=p?++a:--a){i[e][n]=null;T[e][n]=null;A[e][n]=null;L[e][n]=null}}O={};if(t){t.remove()}t=P.rect(-50,-50,z,z).attr({fill:"#233",stroke:"none",opacity:.5});if(c){c.remove()}c=P.rect(-50,-50,z,z).attr({fill:"#233",stroke:"none",opacity:.5});if(U){U.remove()}U=P.rect(-50,-50,z,z).attr({fill:"#141d3d",stroke:"none",opacity:.7});$("#A_clues").empty();return $("#D_clues").empty()};$("#fileupload").fileupload({dataType:"json",add:function(e,t){return t.submit()},done:function(e,t){}});$("#upload_button").click(function(e){return e.preventDefault()});return $.getJSON("/static/puzzle.json",function(e){return N(e)})})}).call(this)
