<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ccts="urn:un:unece:uncefact:documentation:2" xmlns:clm54217="urn:un:unece:uncefact:codelist:specification:54217:2001" xmlns:clm5639="urn:un:unece:uncefact:codelist:specification:5639:1988" xmlns:clm66411="urn:un:unece:uncefact:codelist:specification:66411:2001" xmlns:clmIANAMIMEMediaType="urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:link="http://www.xbrl.org/2003/linkbase" xmlns:n1="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" xmlns:xbrldi="http://xbrl.org/2006/xbrldi" xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="cac cbc ccts clm54217 clm5639 clm66411 clmIANAMIMEMediaType fn link n1 qdt udt xbrldi xbrli xdt xlink xs xsd xsi">	
	<xsl:decimal-format name="european" decimal-separator="," grouping-separator="." NaN=""></xsl:decimal-format>
	<xsl:output version="4.0" method="html" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"></xsl:output>
	<xsl:param name="SV_OutputFormat" select="'HTML'"></xsl:param>
	<xsl:variable name="XML" select="/"></xsl:variable>
	
	
	<xsl:template match="/">
		<html>
			<head>
<script type="text/javascript">
					<![CDATA[var QRCode;!function(){function a(a){this.mode=c.MODE_8BIT_BYTE,this.data=a,this.parsedData=[];for(var b=[],d=0,e=this.data.length;e>d;d++){var f=this.data.charCodeAt(d);f>65536?(b[0]=240|(1835008&f)>>>18,b[1]=128|(258048&f)>>>12,b[2]=128|(4032&f)>>>6,b[3]=128|63&f):f>2048?(b[0]=224|(61440&f)>>>12,b[1]=128|(4032&f)>>>6,b[2]=128|63&f):f>128?(b[0]=192|(1984&f)>>>6,b[1]=128|63&f):b[0]=f,this.parsedData=this.parsedData.concat(b)}this.parsedData.length!=this.data.length&&(this.parsedData.unshift(191),this.parsedData.unshift(187),this.parsedData.unshift(239))}function b(a,b){this.typeNumber=a,this.errorCorrectLevel=b,this.modules=null,this.moduleCount=0,this.dataCache=null,this.dataList=[]}function i(a,b){if(void 0==a.length)throw new Error(a.length+"/"+b);for(var c=0;c<a.length&&0==a[c];)c++;this.num=new Array(a.length-c+b);for(var d=0;d<a.length-c;d++)this.num[d]=a[d+c]}function j(a,b){this.totalCount=a,this.dataCount=b}function k(){this.buffer=[],this.length=0}function m(){return"undefined"!=typeof CanvasRenderingContext2D}function n(){var a=!1,b=navigator.userAgent;return/android/i.test(b)&&(a=!0,aMat=b.toString().match(/android ([0-9]\.[0-9])/i),aMat&&aMat[1]&&(a=parseFloat(aMat[1]))),a}function r(a,b){for(var c=1,e=s(a),f=0,g=l.length;g>=f;f++){var h=0;switch(b){case d.L:h=l[f][0];break;case d.M:h=l[f][1];break;case d.Q:h=l[f][2];break;case d.H:h=l[f][3]}if(h>=e)break;c++}if(c>l.length)throw new Error("Too long data");return c}function s(a){var b=encodeURI(a).toString().replace(/\%[0-9a-fA-F]{2}/g,"a");return b.length+(b.length!=a?3:0)}a.prototype={getLength:function(){return this.parsedData.length},write:function(a){for(var b=0,c=this.parsedData.length;c>b;b++)a.put(this.parsedData[b],8)}},b.prototype={addData:function(b){var c=new a(b);this.dataList.push(c),this.dataCache=null},isDark:function(a,b){if(0>a||this.moduleCount<=a||0>b||this.moduleCount<=b)throw new Error(a+","+b);return this.modules[a][b]},getModuleCount:function(){return this.moduleCount},make:function(){this.makeImpl(!1,this.getBestMaskPattern())},makeImpl:function(a,c){this.moduleCount=4*this.typeNumber+17,this.modules=new Array(this.moduleCount);for(var d=0;d<this.moduleCount;d++){this.modules[d]=new Array(this.moduleCount);for(var e=0;e<this.moduleCount;e++)this.modules[d][e]=null}this.setupPositionProbePattern(0,0),this.setupPositionProbePattern(this.moduleCount-7,0),this.setupPositionProbePattern(0,this.moduleCount-7),this.setupPositionAdjustPattern(),this.setupTimingPattern(),this.setupTypeInfo(a,c),this.typeNumber>=7&&this.setupTypeNumber(a),null==this.dataCache&&(this.dataCache=b.createData(this.typeNumber,this.errorCorrectLevel,this.dataList)),this.mapData(this.dataCache,c)},setupPositionProbePattern:function(a,b){for(var c=-1;7>=c;c++)if(!(-1>=a+c||this.moduleCount<=a+c))for(var d=-1;7>=d;d++)-1>=b+d||this.moduleCount<=b+d||(this.modules[a+c][b+d]=c>=0&&6>=c&&(0==d||6==d)||d>=0&&6>=d&&(0==c||6==c)||c>=2&&4>=c&&d>=2&&4>=d?!0:!1)},getBestMaskPattern:function(){for(var a=0,b=0,c=0;8>c;c++){this.makeImpl(!0,c);var d=f.getLostPoint(this);(0==c||a>d)&&(a=d,b=c)}return b},createMovieClip:function(a,b,c){var d=a.createEmptyMovieClip(b,c),e=1;this.make();for(var f=0;f<this.modules.length;f++)for(var g=f*e,h=0;h<this.modules[f].length;h++){var i=h*e,j=this.modules[f][h];j&&(d.beginFill(0,100),d.moveTo(i,g),d.lineTo(i+e,g),d.lineTo(i+e,g+e),d.lineTo(i,g+e),d.endFill())}return d},setupTimingPattern:function(){for(var a=8;a<this.moduleCount-8;a++)null==this.modules[a][6]&&(this.modules[a][6]=0==a%2);for(var b=8;b<this.moduleCount-8;b++)null==this.modules[6][b]&&(this.modules[6][b]=0==b%2)},setupPositionAdjustPattern:function(){for(var a=f.getPatternPosition(this.typeNumber),b=0;b<a.length;b++)for(var c=0;c<a.length;c++){var d=a[b],e=a[c];if(null==this.modules[d][e])for(var g=-2;2>=g;g++)for(var h=-2;2>=h;h++)this.modules[d+g][e+h]=-2==g||2==g||-2==h||2==h||0==g&&0==h?!0:!1}},setupTypeNumber:function(a){for(var b=f.getBCHTypeNumber(this.typeNumber),c=0;18>c;c++){var d=!a&&1==(1&b>>c);this.modules[Math.floor(c/3)][c%3+this.moduleCount-8-3]=d}for(var c=0;18>c;c++){var d=!a&&1==(1&b>>c);this.modules[c%3+this.moduleCount-8-3][Math.floor(c/3)]=d}},setupTypeInfo:function(a,b){for(var c=this.errorCorrectLevel<<3|b,d=f.getBCHTypeInfo(c),e=0;15>e;e++){var g=!a&&1==(1&d>>e);6>e?this.modules[e][8]=g:8>e?this.modules[e+1][8]=g:this.modules[this.moduleCount-15+e][8]=g}for(var e=0;15>e;e++){var g=!a&&1==(1&d>>e);8>e?this.modules[8][this.moduleCount-e-1]=g:9>e?this.modules[8][15-e-1+1]=g:this.modules[8][15-e-1]=g}this.modules[this.moduleCount-8][8]=!a},mapData:function(a,b){for(var c=-1,d=this.moduleCount-1,e=7,g=0,h=this.moduleCount-1;h>0;h-=2)for(6==h&&h--;;){for(var i=0;2>i;i++)if(null==this.modules[d][h-i]){var j=!1;g<a.length&&(j=1==(1&a[g]>>>e));var k=f.getMask(b,d,h-i);k&&(j=!j),this.modules[d][h-i]=j,e--,-1==e&&(g++,e=7)}if(d+=c,0>d||this.moduleCount<=d){d-=c,c=-c;break}}}},b.PAD0=236,b.PAD1=17,b.createData=function(a,c,d){for(var e=j.getRSBlocks(a,c),g=new k,h=0;h<d.length;h++){var i=d[h];g.put(i.mode,4),g.put(i.getLength(),f.getLengthInBits(i.mode,a)),i.write(g)}for(var l=0,h=0;h<e.length;h++)l+=e[h].dataCount;if(g.getLengthInBits()>8*l)throw new Error("code length overflow. ("+g.getLengthInBits()+">"+8*l+")");for(g.getLengthInBits()+4<=8*l&&g.put(0,4);0!=g.getLengthInBits()%8;)g.putBit(!1);for(;;){if(g.getLengthInBits()>=8*l)break;if(g.put(b.PAD0,8),g.getLengthInBits()>=8*l)break;g.put(b.PAD1,8)}return b.createBytes(g,e)},b.createBytes=function(a,b){for(var c=0,d=0,e=0,g=new Array(b.length),h=new Array(b.length),j=0;j<b.length;j++){var k=b[j].dataCount,l=b[j].totalCount-k;d=Math.max(d,k),e=Math.max(e,l),g[j]=new Array(k);for(var m=0;m<g[j].length;m++)g[j][m]=255&a.buffer[m+c];c+=k;var n=f.getErrorCorrectPolynomial(l),o=new i(g[j],n.getLength()-1),p=o.mod(n);h[j]=new Array(n.getLength()-1);for(var m=0;m<h[j].length;m++){var q=m+p.getLength()-h[j].length;h[j][m]=q>=0?p.get(q):0}}for(var r=0,m=0;m<b.length;m++)r+=b[m].totalCount;for(var s=new Array(r),t=0,m=0;d>m;m++)for(var j=0;j<b.length;j++)m<g[j].length&&(s[t++]=g[j][m]);for(var m=0;e>m;m++)for(var j=0;j<b.length;j++)m<h[j].length&&(s[t++]=h[j][m]);return s};for(var c={MODE_NUMBER:1,MODE_ALPHA_NUM:2,MODE_8BIT_BYTE:4,MODE_KANJI:8},d={L:1,M:0,Q:3,H:2},e={PATTERN000:0,PATTERN001:1,PATTERN010:2,PATTERN011:3,PATTERN100:4,PATTERN101:5,PATTERN110:6,PATTERN111:7},f={PATTERN_POSITION_TABLE:[[],[6,18],[6,22],[6,26],[6,30],[6,34],[6,22,38],[6,24,42],[6,26,46],[6,28,50],[6,30,54],[6,32,58],[6,34,62],[6,26,46,66],[6,26,48,70],[6,26,50,74],[6,30,54,78],[6,30,56,82],[6,30,58,86],[6,34,62,90],[6,28,50,72,94],[6,26,50,74,98],[6,30,54,78,102],[6,28,54,80,106],[6,32,58,84,110],[6,30,58,86,114],[6,34,62,90,118],[6,26,50,74,98,122],[6,30,54,78,102,126],[6,26,52,78,104,130],[6,30,56,82,108,134],[6,34,60,86,112,138],[6,30,58,86,114,142],[6,34,62,90,118,146],[6,30,54,78,102,126,150],[6,24,50,76,102,128,154],[6,28,54,80,106,132,158],[6,32,58,84,110,136,162],[6,26,54,82,110,138,166],[6,30,58,86,114,142,170]],G15:1335,G18:7973,G15_MASK:21522,getBCHTypeInfo:function(a){for(var b=a<<10;f.getBCHDigit(b)-f.getBCHDigit(f.G15)>=0;)b^=f.G15<<f.getBCHDigit(b)-f.getBCHDigit(f.G15);return(a<<10|b)^f.G15_MASK},getBCHTypeNumber:function(a){for(var b=a<<12;f.getBCHDigit(b)-f.getBCHDigit(f.G18)>=0;)b^=f.G18<<f.getBCHDigit(b)-f.getBCHDigit(f.G18);return a<<12|b},getBCHDigit:function(a){for(var b=0;0!=a;)b++,a>>>=1;return b},getPatternPosition:function(a){return f.PATTERN_POSITION_TABLE[a-1]},getMask:function(a,b,c){switch(a){case e.PATTERN000:return 0==(b+c)%2;case e.PATTERN001:return 0==b%2;case e.PATTERN010:return 0==c%3;case e.PATTERN011:return 0==(b+c)%3;case e.PATTERN100:return 0==(Math.floor(b/2)+Math.floor(c/3))%2;case e.PATTERN101:return 0==b*c%2+b*c%3;case e.PATTERN110:return 0==(b*c%2+b*c%3)%2;case e.PATTERN111:return 0==(b*c%3+(b+c)%2)%2;default:throw new Error("bad maskPattern:"+a)}},getErrorCorrectPolynomial:function(a){for(var b=new i([1],0),c=0;a>c;c++)b=b.multiply(new i([1,g.gexp(c)],0));return b},getLengthInBits:function(a,b){if(b>=1&&10>b)switch(a){case c.MODE_NUMBER:return 10;case c.MODE_ALPHA_NUM:return 9;case c.MODE_8BIT_BYTE:return 8;case c.MODE_KANJI:return 8;default:throw new Error("mode:"+a)}else if(27>b)switch(a){case c.MODE_NUMBER:return 12;case c.MODE_ALPHA_NUM:return 11;case c.MODE_8BIT_BYTE:return 16;case c.MODE_KANJI:return 10;default:throw new Error("mode:"+a)}else{if(!(41>b))throw new Error("type:"+b);switch(a){case c.MODE_NUMBER:return 14;case c.MODE_ALPHA_NUM:return 13;case c.MODE_8BIT_BYTE:return 16;case c.MODE_KANJI:return 12;default:throw new Error("mode:"+a)}}},getLostPoint:function(a){for(var b=a.getModuleCount(),c=0,d=0;b>d;d++)for(var e=0;b>e;e++){for(var f=0,g=a.isDark(d,e),h=-1;1>=h;h++)if(!(0>d+h||d+h>=b))for(var i=-1;1>=i;i++)0>e+i||e+i>=b||(0!=h||0!=i)&&g==a.isDark(d+h,e+i)&&f++;f>5&&(c+=3+f-5)}for(var d=0;b-1>d;d++)for(var e=0;b-1>e;e++){var j=0;a.isDark(d,e)&&j++,a.isDark(d+1,e)&&j++,a.isDark(d,e+1)&&j++,a.isDark(d+1,e+1)&&j++,(0==j||4==j)&&(c+=3)}for(var d=0;b>d;d++)for(var e=0;b-6>e;e++)a.isDark(d,e)&&!a.isDark(d,e+1)&&a.isDark(d,e+2)&&a.isDark(d,e+3)&&a.isDark(d,e+4)&&!a.isDark(d,e+5)&&a.isDark(d,e+6)&&(c+=40);for(var e=0;b>e;e++)for(var d=0;b-6>d;d++)a.isDark(d,e)&&!a.isDark(d+1,e)&&a.isDark(d+2,e)&&a.isDark(d+3,e)&&a.isDark(d+4,e)&&!a.isDark(d+5,e)&&a.isDark(d+6,e)&&(c+=40);for(var k=0,e=0;b>e;e++)for(var d=0;b>d;d++)a.isDark(d,e)&&k++;var l=Math.abs(100*k/b/b-50)/5;return c+=10*l}},g={glog:function(a){if(1>a)throw new Error("glog("+a+")");return g.LOG_TABLE[a]},gexp:function(a){for(;0>a;)a+=255;for(;a>=256;)a-=255;return g.EXP_TABLE[a]},EXP_TABLE:new Array(256),LOG_TABLE:new Array(256)},h=0;8>h;h++)g.EXP_TABLE[h]=1<<h;for(var h=8;256>h;h++)g.EXP_TABLE[h]=g.EXP_TABLE[h-4]^g.EXP_TABLE[h-5]^g.EXP_TABLE[h-6]^g.EXP_TABLE[h-8];for(var h=0;255>h;h++)g.LOG_TABLE[g.EXP_TABLE[h]]=h;i.prototype={get:function(a){return this.num[a]},getLength:function(){return this.num.length},multiply:function(a){for(var b=new Array(this.getLength()+a.getLength()-1),c=0;c<this.getLength();c++)for(var d=0;d<a.getLength();d++)b[c+d]^=g.gexp(g.glog(this.get(c))+g.glog(a.get(d)));return new i(b,0)},mod:function(a){if(this.getLength()-a.getLength()<0)return this;for(var b=g.glog(this.get(0))-g.glog(a.get(0)),c=new Array(this.getLength()),d=0;d<this.getLength();d++)c[d]=this.get(d);for(var d=0;d<a.getLength();d++)c[d]^=g.gexp(g.glog(a.get(d))+b);return new i(c,0).mod(a)}},j.RS_BLOCK_TABLE=[[1,26,19],[1,26,16],[1,26,13],[1,26,9],[1,44,34],[1,44,28],[1,44,22],[1,44,16],[1,70,55],[1,70,44],[2,35,17],[2,35,13],[1,100,80],[2,50,32],[2,50,24],[4,25,9],[1,134,108],[2,67,43],[2,33,15,2,34,16],[2,33,11,2,34,12],[2,86,68],[4,43,27],[4,43,19],[4,43,15],[2,98,78],[4,49,31],[2,32,14,4,33,15],[4,39,13,1,40,14],[2,121,97],[2,60,38,2,61,39],[4,40,18,2,41,19],[4,40,14,2,41,15],[2,146,116],[3,58,36,2,59,37],[4,36,16,4,37,17],[4,36,12,4,37,13],[2,86,68,2,87,69],[4,69,43,1,70,44],[6,43,19,2,44,20],[6,43,15,2,44,16],[4,101,81],[1,80,50,4,81,51],[4,50,22,4,51,23],[3,36,12,8,37,13],[2,116,92,2,117,93],[6,58,36,2,59,37],[4,46,20,6,47,21],[7,42,14,4,43,15],[4,133,107],[8,59,37,1,60,38],[8,44,20,4,45,21],[12,33,11,4,34,12],[3,145,115,1,146,116],[4,64,40,5,65,41],[11,36,16,5,37,17],[11,36,12,5,37,13],[5,109,87,1,110,88],[5,65,41,5,66,42],[5,54,24,7,55,25],[11,36,12],[5,122,98,1,123,99],[7,73,45,3,74,46],[15,43,19,2,44,20],[3,45,15,13,46,16],[1,135,107,5,136,108],[10,74,46,1,75,47],[1,50,22,15,51,23],[2,42,14,17,43,15],[5,150,120,1,151,121],[9,69,43,4,70,44],[17,50,22,1,51,23],[2,42,14,19,43,15],[3,141,113,4,142,114],[3,70,44,11,71,45],[17,47,21,4,48,22],[9,39,13,16,40,14],[3,135,107,5,136,108],[3,67,41,13,68,42],[15,54,24,5,55,25],[15,43,15,10,44,16],[4,144,116,4,145,117],[17,68,42],[17,50,22,6,51,23],[19,46,16,6,47,17],[2,139,111,7,140,112],[17,74,46],[7,54,24,16,55,25],[34,37,13],[4,151,121,5,152,122],[4,75,47,14,76,48],[11,54,24,14,55,25],[16,45,15,14,46,16],[6,147,117,4,148,118],[6,73,45,14,74,46],[11,54,24,16,55,25],[30,46,16,2,47,17],[8,132,106,4,133,107],[8,75,47,13,76,48],[7,54,24,22,55,25],[22,45,15,13,46,16],[10,142,114,2,143,115],[19,74,46,4,75,47],[28,50,22,6,51,23],[33,46,16,4,47,17],[8,152,122,4,153,123],[22,73,45,3,74,46],[8,53,23,26,54,24],[12,45,15,28,46,16],[3,147,117,10,148,118],[3,73,45,23,74,46],[4,54,24,31,55,25],[11,45,15,31,46,16],[7,146,116,7,147,117],[21,73,45,7,74,46],[1,53,23,37,54,24],[19,45,15,26,46,16],[5,145,115,10,146,116],[19,75,47,10,76,48],[15,54,24,25,55,25],[23,45,15,25,46,16],[13,145,115,3,146,116],[2,74,46,29,75,47],[42,54,24,1,55,25],[23,45,15,28,46,16],[17,145,115],[10,74,46,23,75,47],[10,54,24,35,55,25],[19,45,15,35,46,16],[17,145,115,1,146,116],[14,74,46,21,75,47],[29,54,24,19,55,25],[11,45,15,46,46,16],[13,145,115,6,146,116],[14,74,46,23,75,47],[44,54,24,7,55,25],[59,46,16,1,47,17],[12,151,121,7,152,122],[12,75,47,26,76,48],[39,54,24,14,55,25],[22,45,15,41,46,16],[6,151,121,14,152,122],[6,75,47,34,76,48],[46,54,24,10,55,25],[2,45,15,64,46,16],[17,152,122,4,153,123],[29,74,46,14,75,47],[49,54,24,10,55,25],[24,45,15,46,46,16],[4,152,122,18,153,123],[13,74,46,32,75,47],[48,54,24,14,55,25],[42,45,15,32,46,16],[20,147,117,4,148,118],[40,75,47,7,76,48],[43,54,24,22,55,25],[10,45,15,67,46,16],[19,148,118,6,149,119],[18,75,47,31,76,48],[34,54,24,34,55,25],[20,45,15,61,46,16]],j.getRSBlocks=function(a,b){var c=j.getRsBlockTable(a,b);if(void 0==c)throw new Error("bad rs block @ typeNumber:"+a+"/errorCorrectLevel:"+b);for(var d=c.length/3,e=[],f=0;d>f;f++)for(var g=c[3*f+0],h=c[3*f+1],i=c[3*f+2],k=0;g>k;k++)e.push(new j(h,i));return e},j.getRsBlockTable=function(a,b){switch(b){case d.L:return j.RS_BLOCK_TABLE[4*(a-1)+0];case d.M:return j.RS_BLOCK_TABLE[4*(a-1)+1];case d.Q:return j.RS_BLOCK_TABLE[4*(a-1)+2];case d.H:return j.RS_BLOCK_TABLE[4*(a-1)+3];default:return void 0}},k.prototype={get:function(a){var b=Math.floor(a/8);return 1==(1&this.buffer[b]>>>7-a%8)},put:function(a,b){for(var c=0;b>c;c++)this.putBit(1==(1&a>>>b-c-1))},getLengthInBits:function(){return this.length},putBit:function(a){var b=Math.floor(this.length/8);this.buffer.length<=b&&this.buffer.push(0),a&&(this.buffer[b]|=128>>>this.length%8),this.length++}};var l=[[17,14,11,7],[32,26,20,14],[53,42,32,24],[78,62,46,34],[106,84,60,44],[134,106,74,58],[154,122,86,64],[192,152,108,84],[230,180,130,98],[271,213,151,119],[321,251,177,137],[367,287,203,155],[425,331,241,177],[458,362,258,194],[520,412,292,220],[586,450,322,250],[644,504,364,280],[718,560,394,310],[792,624,442,338],[858,666,482,382],[929,711,509,403],[1003,779,565,439],[1091,857,611,461],[1171,911,661,511],[1273,997,715,535],[1367,1059,751,593],[1465,1125,805,625],[1528,1190,868,658],[1628,1264,908,698],[1732,1370,982,742],[1840,1452,1030,790],[1952,1538,1112,842],[2068,1628,1168,898],[2188,1722,1228,958],[2303,1809,1283,983],[2431,1911,1351,1051],[2563,1989,1423,1093],[2699,2099,1499,1139],[2809,2213,1579,1219],[2953,2331,1663,1273]],o=function(){var a=function(a,b){this._el=a,this._htOption=b};return a.prototype.draw=function(a){function g(a,b){var c=document.createElementNS("http://www.w3.org/2000/svg",a);for(var d in b)b.hasOwnProperty(d)&&c.setAttribute(d,b[d]);return c}var b=this._htOption,c=this._el,d=a.getModuleCount();Math.floor(b.width/d),Math.floor(b.height/d),this.clear();var h=g("svg",{viewBox:"0 0 "+String(d)+" "+String(d),width:"100%",height:"100%",fill:b.colorLight});h.setAttributeNS("http://www.w3.org/2000/xmlns/","xmlns:xlink","http://www.w3.org/1999/xlink"),c.appendChild(h),h.appendChild(g("rect",{fill:b.colorDark,width:"1",height:"1",id:"template"}));for(var i=0;d>i;i++)for(var j=0;d>j;j++)if(a.isDark(i,j)){var k=g("use",{x:String(i),y:String(j)});k.setAttributeNS("http://www.w3.org/1999/xlink","href","#template"),h.appendChild(k)}},a.prototype.clear=function(){for(;this._el.hasChildNodes();)this._el.removeChild(this._el.lastChild)},a}(),p="svg"===document.documentElement.tagName.toLowerCase(),q=p?o:m()?function(){function a(){this._elImage.src=this._elCanvas.toDataURL("image/png"),this._elImage.style.display="block",this._elCanvas.style.display="none"}function d(a,b){var c=this;if(c._fFail=b,c._fSuccess=a,null===c._bSupportDataURI){var d=document.createElement("img"),e=function(){c._bSupportDataURI=!1,c._fFail&&_fFail.call(c)},f=function(){c._bSupportDataURI=!0,c._fSuccess&&c._fSuccess.call(c)};return d.onabort=e,d.onerror=e,d.onload=f,d.src="data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==",void 0}c._bSupportDataURI===!0&&c._fSuccess?c._fSuccess.call(c):c._bSupportDataURI===!1&&c._fFail&&c._fFail.call(c)}if(this._android&&this._android<=2.1){var b=1/window.devicePixelRatio,c=CanvasRenderingContext2D.prototype.drawImage;CanvasRenderingContext2D.prototype.drawImage=function(a,d,e,f,g,h,i,j){if("nodeName"in a&&/img/i.test(a.nodeName))for(var l=arguments.length-1;l>=1;l--)arguments[l]=arguments[l]*b;else"undefined"==typeof j&&(arguments[1]*=b,arguments[2]*=b,arguments[3]*=b,arguments[4]*=b);c.apply(this,arguments)}}var e=function(a,b){this._bIsPainted=!1,this._android=n(),this._htOption=b,this._elCanvas=document.createElement("canvas"),this._elCanvas.width=b.width,this._elCanvas.height=b.height,a.appendChild(this._elCanvas),this._el=a,this._oContext=this._elCanvas.getContext("2d"),this._bIsPainted=!1,this._elImage=document.createElement("img"),this._elImage.style.display="none",this._el.appendChild(this._elImage),this._bSupportDataURI=null};return e.prototype.draw=function(a){var b=this._elImage,c=this._oContext,d=this._htOption,e=a.getModuleCount(),f=d.width/e,g=d.height/e,h=Math.round(f),i=Math.round(g);b.style.display="none",this.clear();for(var j=0;e>j;j++)for(var k=0;e>k;k++){var l=a.isDark(j,k),m=k*f,n=j*g;c.strokeStyle=l?d.colorDark:d.colorLight,c.lineWidth=1,c.fillStyle=l?d.colorDark:d.colorLight,c.fillRect(m,n,f,g),c.strokeRect(Math.floor(m)+.5,Math.floor(n)+.5,h,i),c.strokeRect(Math.ceil(m)-.5,Math.ceil(n)-.5,h,i)}this._bIsPainted=!0},e.prototype.makeImage=function(){this._bIsPainted&&d.call(this,a)},e.prototype.isPainted=function(){return this._bIsPainted},e.prototype.clear=function(){this._oContext.clearRect(0,0,this._elCanvas.width,this._elCanvas.height),this._bIsPainted=!1},e.prototype.round=function(a){return a?Math.floor(1e3*a)/1e3:a},e}():function(){var a=function(a,b){this._el=a,this._htOption=b};return a.prototype.draw=function(a){for(var b=this._htOption,c=this._el,d=a.getModuleCount(),e=Math.floor(b.width/d),f=Math.floor(b.height/d),g=['<table style="border:0;border-collapse:collapse;">'],h=0;d>h;h++){g.push("<tr>");for(var i=0;d>i;i++)g.push('<td style="border:0;border-collapse:collapse;padding:0;margin:0;width:'+e+"px;height:"+f+"px;background-color:"+(a.isDark(h,i)?b.colorDark:b.colorLight)+';"></td>');g.push("</tr>")}g.push("</table>"),c.innerHTML=g.join("");var j=c.childNodes[0],k=(b.width-j.offsetWidth)/2,l=(b.height-j.offsetHeight)/2;k>0&&l>0&&(j.style.margin=l+"px "+k+"px")},a.prototype.clear=function(){this._el.innerHTML=""},a}();QRCode=function(a,b){if(this._htOption={width:256,height:256,typeNumber:4,colorDark:"#000000",colorLight:"#ffffff",correctLevel:d.H},"string"==typeof b&&(b={text:b}),b)for(var c in b)this._htOption[c]=b[c];"string"==typeof a&&(a=document.getElementById(a)),this._android=n(),this._el=a,this._oQRCode=null,this._oDrawing=new q(this._el,this._htOption),this._htOption.text&&this.makeCode(this._htOption.text)},QRCode.prototype.makeCode=function(a){this._oQRCode=new b(r(a,this._htOption.correctLevel),this._htOption.correctLevel),this._oQRCode.addData(a),this._oQRCode.make(),this._el.title=a,this._oDrawing.draw(this._oQRCode),this.makeImage()},QRCode.prototype.makeImage=function(){"function"==typeof this._oDrawing.makeImage&&(!this._android||this._android>=3)&&this._oDrawing.makeImage()},QRCode.prototype.clear=function(){this._oDrawing.clear()},QRCode.CorrectLevel=d}();]]></script>
                
				
				<style type="text/css">
					body {
					    background-color: #FFFFFF;
					    font-family: 'Tahoma', "Times New Roman", Times, serif;
					    font-size: 11px;
					    color: #666666;
					}
					h1, h2 {
					    padding-bottom: 3px;
					    padding-top: 3px;
					    margin-bottom: 5px;
					    text-transform: uppercase;
					    font-family: Arial, Helvetica, sans-serif;
					}
					h1 {
					    font-size: 1.4em;
					    text-transform:none;
					}
					h2 {
					    font-size: 1em;
					    color: brown;
					}
					h3 {
					    font-size: 1em;
					    color: #333333;
					    text-align: justify;
					    margin: 0;
					    padding: 0;
					}
					h4 {
					    font-size: 1.1em;
					    font-style: bold;
					    font-family: Arial, Helvetica, sans-serif;
					    color: #000000;
					    margin: 0;
					    padding: 0;
					}
					hr {
					    height:2px;
					    color: #000000;
					    background-color: #000000;
					    border-bottom: 1px solid #000000;
					}
					p, ul, ol {
					    margin-top: 1.5em;
					}
					ul, ol {
					    margin-left: 3em;
					}
					blockquote {
					    margin-left: 3em;
					    margin-right: 3em;
					    font-style: italic;
					}
					a {
					    text-decoration: none;
					    color: #70A300;
					}
					a:hover {
					    border: none;
					    color: #70A300;
					}
					#despatchTable {
					    border-collapse:collapse;
					    font-size:11px;
					    float:right;
					    border-color:gray;
					}
					#ettnTable {
					    border-collapse:collapse;
					    font-size:11px;
					    border-color:gray;
					}
					#customerPartyTable {
					    border-width: 0px;
					    border-spacing:;
					    border-style: inset;
					    border-color: gray;
					    border-collapse: collapse;
					    background-color:
					}
					#customerIDTable {
					    border-width: 2px;
					    border-spacing:;
					    border-style: inset;
					    border-color: gray;
					    border-collapse: collapse;
					    background-color:
					}
					#customerIDTableTd {
					    border-width: 2px;
					    border-spacing:;
					    border-style: inset;
					    border-color: gray;
					    border-collapse: collapse;
					    background-color:
					}
					#lineTable {
					    border-width:2px;
					    border-spacing:;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:;
					}
					#lineTableTd {
					    border-width: 1px;
					    padding: 1px;
					    border-style: inset;
					    border-color: black;
					    background-color: white;
					}
					#lineTableTr {
					    border-width: 1px;
					    padding: 0px;
					    border-style: inset;
					    border-color: black;
					    background-color: white;
					    -moz-border-radius:;
					}
					#lineTableDummyTd {
					    border-width: 1px;
					    border-color:white;
					    padding: 1px;
					    border-style: inset;
					    border-color: black;
					    background-color: white;
					}
					#lineTableBudgetTd {
					    border-width: 2px;
					    border-spacing:0px;
					    padding: 1px;
					    border-style: inset;
					    border-color: black;
					    background-color: white;
					    -moz-border-radius:;
					}
					#notesTable {
					    border-width: 2px;
					    border-spacing:;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:
					}
					#notesTableTd {
					    border-width: 0px;
					    border-spacing:;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:
					}
					#bankTable {
					    border-width: 2px;
					    border-spacing:;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:
					}
					#bankTableTd {
					    border-width: 0px;
					    border-spacing:;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:
					}
					table {
					    border-spacing:0px;
					}
					#budgetContainerTable {
					    border-width: 0px;
					    border-spacing: 0px;
					    border-style: inset;
					    border-color: black;
					    border-collapse: collapse;
					    background-color:;
					}
					td {
					    border-color:gray;
					}</style>
				<title>e-Arşiv</title>
			</head>
			<body style="margin-left=0.6in; margin-right=0.6in; margin-top=0.79in; margin-bottom=0.79in">
				<xsl:for-each select="$XML">
					<table style="border-color:blue; " border="0" cellspacing="0px" width="800" cellpadding="0px">
						<tbody>
							<tr valign="top">
								<td width="40%">
									<br />
									<table align="center" border="0" width="100%">
										<tbody>
											<hr />
											<tr align="left">
												<xsl:for-each select="n1:Invoice/cac:AccountingSupplierParty/cac:Party">
													<td align="left">
													<xsl:if test="cac:PartyName">
													<xsl:value-of select="cac:PartyName/cbc:Name"></xsl:value-of>
													<br />
													</xsl:if>
													<xsl:for-each select="cac:Person">
														<xsl:for-each select="cbc:Title">
														<xsl:apply-templates></xsl:apply-templates>
														<xsl:text>&#160;</xsl:text>
														</xsl:for-each>
														<xsl:for-each select="cbc:FirstName">
														<xsl:apply-templates></xsl:apply-templates>
														<xsl:text>&#160;</xsl:text>
														</xsl:for-each>
														<xsl:for-each select="cbc:MiddleName">
														<xsl:apply-templates></xsl:apply-templates>
														<xsl:text>&#160;</xsl:text>
														</xsl:for-each>
														<xsl:for-each select="cbc:FamilyName">
														<xsl:apply-templates></xsl:apply-templates>
														<xsl:text>&#160;</xsl:text>
														</xsl:for-each>
														<xsl:for-each select="cbc:NameSuffix">
														<xsl:apply-templates></xsl:apply-templates>
														</xsl:for-each>
													</xsl:for-each>
													</td>
												</xsl:for-each>
											</tr>
											<tr align="left">
												<xsl:for-each select="n1:Invoice/cac:AccountingSupplierParty/cac:Party">
												<td align="left">
												<xsl:for-each select="cac:PostalAddress">
													<xsl:for-each select="cbc:StreetName">
													<xsl:apply-templates></xsl:apply-templates>
													<xsl:text>&#160;</xsl:text>
													</xsl:for-each>
													<xsl:for-each select="cbc:BuildingName">
													<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
													<xsl:if test="cbc:BuildingNumber">
													<xsl:text> No:</xsl:text>
													<xsl:for-each select="cbc:BuildingNumber">
													<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
													<xsl:text>&#160;</xsl:text>
													</xsl:if>
													<br />
													<xsl:for-each select="cbc:PostalZone">
													<xsl:apply-templates></xsl:apply-templates>
													<xsl:text>&#160;</xsl:text>
													</xsl:for-each>
													<xsl:for-each select="cbc:CitySubdivisionName">
													<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
													<xsl:text>/ </xsl:text>
													<xsl:for-each select="cbc:CityName">
													<xsl:apply-templates></xsl:apply-templates>
													<xsl:text>&#160;</xsl:text>
													</xsl:for-each>
												</xsl:for-each>
												</td>
												</xsl:for-each>
											</tr>
											<xsl:if test="//n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone or //n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telefax">
												<tr align="left">
													<xsl:for-each select="n1:Invoice/cac:AccountingSupplierParty/cac:Party">														
														<td align="left">
														<xsl:for-each select="cac:Contact">
														<xsl:if test="cbc:Telephone">
														<xsl:text>Tel: </xsl:text>
														<xsl:for-each select="cbc:Telephone">
														<xsl:apply-templates></xsl:apply-templates>
														</xsl:for-each>
														</xsl:if>
														<xsl:if test="cbc:Telefax">
														<xsl:text> Fax: </xsl:text>
														<xsl:for-each select="cbc:Telefax">
														<xsl:apply-templates></xsl:apply-templates>
														</xsl:for-each>
														</xsl:if>
														<xsl:text>&#160;</xsl:text>
														</xsl:for-each>
														</td>
													</xsl:for-each>
												</tr>
											</xsl:if>
											<xsl:for-each select="//n1:Invoice/cac:AccountingSupplierParty/cac:Party/cbc:WebsiteURI">
												<tr align="left">
												<td>
												<xsl:text>Web Sitesi: </xsl:text>
												<xsl:value-of select="."></xsl:value-of>
												</td>
												</tr>
											</xsl:for-each>
											<xsl:for-each select="//n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail">
												<tr align="left">
												<td>
												<xsl:text>E-Posta: </xsl:text>
												<xsl:value-of select="."></xsl:value-of>
												</td>
												</tr>
											</xsl:for-each>
											<tr align="left">
												<xsl:for-each select="n1:Invoice/cac:AccountingSupplierParty/cac:Party">																											
													<td align="left">
													<xsl:text>Vergi Dairesi: </xsl:text>
													<xsl:for-each select="cac:PartyTaxScheme">
													<xsl:for-each select="cac:TaxScheme">
													<xsl:for-each select="cbc:Name">
													<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
													</xsl:for-each>
													<xsl:text>&#160; </xsl:text>
													</xsl:for-each>
													</td>
												</xsl:for-each>
											</tr>
											<xsl:for-each select="//n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification">
												<tr align="left">
												<td>
												<xsl:value-of select="cbc:ID/@schemeID"></xsl:value-of>
												<xsl:text>: </xsl:text>
												<xsl:value-of select="cbc:ID"></xsl:value-of>
												</td>
												</tr>
											</xsl:for-each>
											<tr align="left">
												<td>
													<xsl:text>Firma Tamamlayıcı No: 2667269248177</xsl:text>
												</td>
											</tr>											
										</tbody>
									</table>
									<hr />
								</td>
								<td width="20%" align="center" valign="middle">
									<br />
									<br />
									<img style="width:91px;" align="middle" alt="E-Fatura Logo" src="data:image/jpeg;base64,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" />
									<h1 align="center">
										<span style="font-weight:bold; ">
											<xsl:text>e-Arşiv</xsl:text>
										</span>
									</h1>
								</td>								
							<td width="20%" align="right" valign="middle">
								<div id="qrcode"></div>
                                <div id="qrvalue" style="display: none">
                                    {
										<xsl:variable name="vkn" select="n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID=('VKN', 'TCKN')][1]/cbc:ID"></xsl:variable>
									    "vkntckn": "<xsl:value-of select="$vkn"></xsl:value-of>",
										
										<xsl:variable name="avkn" select="n1:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID=('VKN', 'TCKN')][1]/cbc:ID"></xsl:variable>
                                        "avkntckn": "<xsl:value-of select="$avkn"></xsl:value-of>",
										
                                        "senaryo": "<xsl:value-of select="n1:Invoice/cbc:ProfileID"></xsl:value-of>",
                                        "tip": "<xsl:value-of select="n1:Invoice/cbc:InvoiceTypeCode"></xsl:value-of>",
                                        "tarih": "<xsl:value-of select="n1:Invoice/cbc:IssueDate"></xsl:value-of>",
                                        "no": "<xsl:value-of select="n1:Invoice/cbc:ID"></xsl:value-of>",
                                        "ettn": "<xsl:value-of select="n1:Invoice/cbc:UUID"></xsl:value-of>",
										"parabirimi": "<xsl:value-of select="n1:Invoice/cbc:DocumentCurrencyCode"></xsl:value-of>",
										"malhizmettoplam": "<xsl:value-of select="n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount"></xsl:value-of>",
										<xsl:for-each select="n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
											<xsl:if test="cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode='0015'">
											  "kdvmatrah(<xsl:value-of select="cbc:Percent"></xsl:value-of>)": "<xsl:value-of select="cbc:TaxableAmount"></xsl:value-of>",
											  "hesaplanankdv(<xsl:value-of select="cbc:Percent"></xsl:value-of>)": "<xsl:value-of select="cbc:TaxAmount"></xsl:value-of>",
											</xsl:if>
										</xsl:for-each>
										"vergidahil": "<xsl:value-of select="n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount"></xsl:value-of>",
										"odenecek": "<xsl:value-of select="n1:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount"></xsl:value-of>"
                                    }
                                </div>
                                <script type="text/javascript">
                                    var qrcode = new QRCode(document.getElementById("qrcode"), {
                                        width : 150,
                                        height : 150,
										correctLevel: QRCode.CorrectLevel.L
                                    });
                                    function makeCode (msg) {
                                        qrcode.makeCode(msg);
                                    }
                                    makeCode(JSON.stringify(JSON.parse(document.getElementById("qrvalue").innerHTML)));
                                </script>
								<div width="40%" align="right" valign="middle">
								  <br />
								  <img style="width:240px;" align="center" alt="Company Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdCIFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAAABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAAAABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAAACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAG0A6oDASIAAhEBAxEB/8QAHgABAAAGAwEAAAAAAAAAAAAAAAECBgcICQMEBQr/xABnEAABAwMBBQMGBgsHDgsIAgMBAAIDBAUGEQcIEiExQVFhCRMicYGRFDJCgqHSFSNSYnKSlaKx0dMWGUOTlLLBGCQzR1NXY3ODhIWjs8IXJTQ3REZUVVZ1wyc1NkVldLThZKTi8PH/xAAcAQEAAgMBAQEAAAAAAAAAAAAABAUBAgMGBwj/xABCEQACAQICBQkHAwMCBQUBAAAAAQIDBAURBhIhMVEUQVJhcYGRodETFSIyscHwM0LhI0NiB4IWJFNyklSiwtLxsv/aAAwDAQACEQMRAD8A2loiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCKCagICKKHPuK8645LjtnHFd7/AG2hA6mpq44v5xCyk5bEYlJRWcnkekit1d94jYfY3OZX7UMf4mdWw1QnPuj1VHXPfV2A25xbDkFyuGn/AGW2SkH2vDQpULC6qfJTk+5kCri1hQ/UrRX+5F9kWLlz3/tnMLnNs+GZFWgfFdKYYAfe4kKl67ygla8Ftq2XwNOp0dU3Rx5dnJsf9KkxwW+l/by7WvUrauleEUt9bPsTf2My1DXTqsErhv3bVKsEW7HcaoR2ExTTH6XgfQqbrd8fb1VAiPJKClBP8Ba4Qfzg5dFgd1z5LvIFTTjC4fKpS7F6tGxDVTAHuK1mXDeZ28XEky7TLrFqddKdkMI/NYF4FVtl2tVvKr2mZPKOLi53OUc/YQjwapH5pIjS08tf2UpPtyX3ZtSPIankuvNX0VMGmorKeIOOg45Wt1PhqVqdq8uyu46muyi81Bdrr524TP119bl5stRUS6Caolk4egfIXae9aPDNXfLyOMtOl+2h/wC7+DbNV5bi1AQ2uya005PQS10TNfe5efU7TdnFHH52qz/HImggauukPX8ZapC1hOrmNPrAUNGNPJgHqC4zs1DnOf8AxvWl8tFeL9DakdsWydvXaZi/5Vh+spHbaNkTfjbTsXH+lIfrLVeXDsCl4x3KHOKgbrTK4f8AaXizaf8A8Nux4f20MX/KkX61A7cNjg67UMY/KcX61qyDgmoUSdZxOi0uuH/bXmbUqbbLskrHFtPtMxh5b1/40hH6XLts2n7NpBrHtBxpwHddYPrLVEeE9QCjWs15xt9wUWV7KPMdo6V1nvprxZtxpsnxutiZPR5DbJ45PiPjq43B3qIPNdyOtpJiRDVQvLeobI06e4rUSx/D8VoBHcF2IrhWQ6mGqmjLuR4JC3X3FcpYnKP7fP8AgkR0ok99Lz/g26A6jUcwe7mhOnUFam6bMcsozrR5ReICG8AMdfK30e7k7ovfoNue2G1nWi2l5GzkBo+udINPU/Vc/fUF80H4kmOktN/NTfibROIKIOq1tUO9Rt7ouHg2h1Mwb2VFJTyA+vWPU+9VVad9zbPb2htfHj90HaZ6F0bvfG9o+hZWO237k14epIhpFay3pruXqZ+IsMbVv+XyMtbfNm1DOPlOo7g+M+xr2u/Sq8sW/Xstrmht9sOQWqQ9SIY6lg9rHcX5qkQxezns18u3NEunjFnU3Ty7U0ZJIrV2Peh2FX7hbT7QaKlkcdPN18clMR7ZGgfSriWrILDfYhPZL3QXCMjUPpalkoP4pKmU7ilV/Tkn2MnU69Kr+nJPsZ6CKBIHXkgOq7HUiiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIg59EAReDkGeYTikbpcky20W0M6iprGMd+KTqfcrYZFvibDbFxNpb9WXmRvybfRPcCfw38LfpXSFGpU+SLZrKcYfMy9qLD/ACPf8A4o8R2dk/cy3Kt09vBGD/OVsb/vobcbwHMorpa7PG7oKKgaXgfhSl6mU8MuJ70l2sizvqUOLNh2h66KnMg2jYBiocckzWx23g6tqa6NjvxSdVrHyLaxtMyouOQ57fa5rurH1r2s/EaQ36FRszi95kdzcerj1PtU6lgqf6k/BEKrirj8kPFmyK/74uwKxcTY8vlukjfk26illB9TiA36Vbi++UHw+n4m43s+vNcfkvrKmKmb7m8ZWDziSuNx8FYUsHtI/Mm+/wBMisr4tdNfC0u71zMor95QDaVWh0dgxDH7YD8V8rpal495aPoVvr3vebwV7Jac8dQMPyaCihh09vCXfSrNAiR4jj9N5PJreZPsHNVVj+yradlDmjH9nuQ1wf0fHb5Az8ZwDfpVjC0sqCz1Irt/kpq13fV3kpyfZn9jlu21LaZkPEb5tByOtD/jNluUvCfmggfQqZnkfO/zk7jK49XSHiPvKvTY9zjb/eA10uJU9sY75VfXxMI+a0uP0KvrN5PvPaotOQZ3Y6Bp+M2mglqXD38AXZYlZW+zXiuz+Cuq4RiF3upyfb/Jipx6Dly9Shx6rOS0eTzwqHhN/wBod9rfum0tPDTg+ouDyq1tW49sCtxaaqz3e5FvX4XdJND6xHwhcJ6RWUNzb7F65GkdDsSq71GPa/TM11MkA5nkuWOphcdGysJ7g4araBbN2fYJZ9DR7K7C4jnxVMBqD75C5VjbMHwqytDbNiFkoQ3oKa3wx6e5qg1dJaT+SD78l6kmnoDcS/UrRXYm/Q1T22xZBdeVrx+6VmvT4PRSyfzWlVLQbGtr10OlDsxyeTUa6utksYPteAFtPaA0BrRwgdg5BR69eagT0gnL5YLxJ1PQCiv1K7fYkvuzWpbd1jb1dAx0ezyrpw89aqogh09Yc/Ue5e/QblW3SscwVFus9EHa6me5tPB6wwO+jVbC9B3KKhzxivLmX53k+noPh8PmlN969DBOi3DtqcjWmryXGafV2jgJppCB38oxqvSj3Bc1dK0T5/Ymx6jiLaWZzgPActfes2kUeV/WlzkyOiGFpZarf+5mHMfk/qvX7btRg0+9tDv6ZV2YfJ+U5cfhW1KTh05ebtIB19sqy9RcZXNSW9neOi+Fx/t+cvUxHHk+LQfjbUq/2WqP9oo/vfFl7dqNw/Jcf11lui5OTlvOq0cwxf2vOXqYkfvfVkHTajcPyXH9dSO8n1bfkbU6seu0sP8A6iy6RcnTjLejb/h/Df8Ap+b9TDWr8n3XBx+A7Uqct19Hz9pdr7eGVedWbgOYxcH2P2iWWfX4/nqOaLT1aF2v0LNtFxdrSlvRq9HsPe6GXe/UwOq9xPa1A2Q0t9xmp4fiAVMrC8e2PkvCrdzTbvSv4YbFa6saA8UF0i93p8JWw5Q0C5Sw+jLic3o3Zc2a7/4Nadx3Y9vFsYXzbN7lKAdP62khmPuY8lUTedn+fY8XfZzB8goA06F09sma0fO4dPpW2LQdyEnvPvUSpgtOXyyaOM9GqL+SbXbk/Q0/GeKN/mpXhjx1a70T7iuZujgNOYW2W74ri9/aY77jdquLXdRV0ccuv4zSqHu+7VsKvXEanZtaYHO+XRtdSkfxZAUGpgNT9k1+eJEno1VXyVE+1ZeprSLSFFrNexZ15BuM7LbiHPsN7v1nkPxR55lTGPY9vF+craX/AHEs4oQ6TGMws91aOjKmOSkkPtHG36Qq+tg91T3Rz7CJUwa8pftz7GYyNZpy0Xboaqpt8raihqJaaZp1EkLzG4e1uhVd5TsC2vYZxvvWB3J0DOZqKNnwqLTv4ouLQesBUG6Mse6NwLXtOjmkaOb6x1CqKtKdKWU00+sgyhOlLKaafWV/j+3/AGx4yGttm0C6ujb0iqpBUs07tJQ5XOxzfqzy1uZFlOKWq8xDk6Sne6klPj8ph9wWOPCuKSInsW9G/urd/wBOo/HNeDJdG9uKXyTf52me2Ib6GyHImxxXt1yx2odyIrKcyxA/4yLiGniQFebH8txfK6YVeM5DbrpCRrxUlSyXT1gHUe1apI2Fq71uuNda6llbba2ekqWHVs0Ejo3j1OaQVbUdJK9PZWipeTLWjjlaOypFPyNsWqite+G71e2LEnRxVF+ZfaRnIwXSPzpI8JRpIPaSr/4JvpbPb8Y6PMqGpxqrdoDKdailJ/DaOJvzm6eKu7XHrO42Seq+v13FtQxa2rPJvVfX6mRKLzrNf7LkVBHdLBd6O5Ucg1bPSzNlYfa0r0AdVcpqSzRZJprNEURFkyEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBEUEBFERAEREAREQBERAEREAREQBERAEREARE69EARU3k+0jAsNY52T5bbKBzf4KScGU+pg1cfcrQZTvn7PLVxRY1Z7pfJRqA8tFLD+M/V35q3jSnP5UYzyMg1AkNaXOIDRzJPQLCLJd8rajduKOw0lpsUR6GOE1EoH4Uno/mq0uTbS8/y4u/dLmN2uDHdYpKlwj/ABG6N+hSI2c38zyMOWRsDyjbTsrw7ibf86tUMrOsEU3n5fVwR6n6FaHKN+XZ9bC6LGcbvF5kGuj5eGliJ9btX/mrC2QgdAB6gunKCVKhZU18200c3zGQmTb7+1S68UePWuy2OM9HNidUygfhP9HX5qtRke2raxlfE2+7QL1PG/rFHUmGP8WPhCox/ojU9F2rTZL3kNQKXH7NX3Odx0EdHTPmdr6mgqVGnTp7UkcpZs6kkjpZDLKS97uZe46k+081wvJV5cX3StuWTBksmLx2WB/8JdKlkRA/AbxP+gK7mM7gsWjJcz2hPceRfBa6QNHq85IT/NWzvKUN8ji6EpbkYcOdpzUsJdUyiClY6eVx0EcTS9xPgBqVsexzdB2D49wvmxF95mbofOXSqfPqfwNQz81XQseIYrjEYixvGbVa2AaAUdHHDy+aAuUsVhH5ItmvIXL5mazMZ2DbZcvDZLJs3vboX9JqmD4NH6+KUt19iujj+4dtYuha+/3qw2aM6cTfPPqZB7GAN/OWfOhPX6UXCWL138qSNlhtL92bMU8e8n5hNMGPynOrzcXjm5lHFHSsPhqQ930q5Ni3Q936xBrhgkdxkb/CXGqlqCfml3D9CvIiizv7mpvm+7Z9DtGyt4boL6/U8Gx4Dg+MsYzHcPsttDOhpaCKM+8N1Xvc+mqIospOTzk8yTGKisorIhoFFEWDIREQBERAEREAREQBERAEREAREQBERAEREAREQBERAQ05qBHcpkQyQA71AjmpkQwQA06HRUtl2y3Z5nkbm5Zh9suD3DTz74QyceqVujx71VSLWcI1FqzWaNZwjUWUlmjGDM9xzGa0SVOCZRV2yU8201wHwiH1B40e0eviWPue7ve1LZ4H1F6xuSqoWc/h1v1qIAO93COJnzmhbIUVPdYDa19sFqvq3eH/AOFXXwa2q7YLVfV6GpqI0scrH1ELpogfSYyTgJHg7Q6H2Fe/QYnQ5EA3Fr3FJVnQC3XEspah57onk+alPhxMcfuVnntH3bdl+0dktTU2ZtouknMXC2tbE8u73s04JPaNfELEvanuz53svimuXmW3yxs5mvpIzrE3/DR8yz182+IXmL3Briz+NrWjxX56opq+F1bba1rR4otTdbRdbFWvtt5tlVQVcY1fBUwuikA7+FwB08ei6Dhqq7sW1G8W+hix7JKGjyvHmchbLsDIIR3004Pnad2nQsdw/elVPRbIsP2nwSVOxvIJYbsxhkkxi+SsbUkADX4PUDRkzRz5OAcB8YhV0LdV/wBF5vhufdx7tvURFaup+ltfDn/n69RbbFMtynCri264nfq21VQOpfTSlof4Pb8V48HArJ/Zfvpvc6K1bU7WNDo37K2+Pp4yw/0s/FWMF9xq+4tcpLRkdoq7bWxfGgqYix/rGvUeI1HivNceHot7a/ucPn/TeXU93h+M2o3da0fwPLq/g2pY/kthyq2RXnHLvS3KimHozU8ge31HTofA6EL01q4wvaBl+z26tvOIXyot1QCPONYeKKZv3MkZ9F49Y1HYQszNjG9fiu0B1Pj2XiGw5BJoxmrj8Eq3f4N5+I4/cO9hK9hh+PULtqnV+GXk+89FZ4tTuPgqfDLyL9oiK/LYIiIAiIgCIiAIiIAiIgCIiAIiIAiIgChqFFQ4UBFERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAERdeuuFBa6Z1bc62npKdnN0s8rY2N9ZcQEB2EVo8s3oNluN8cVvuE99qG8gy3x6x6+MrtG+7VWWy3fAzy5ccGLWm32SE8myPHwmfT1u0YD80rtGhOXMYckjMGoqKekgdU1U8cMLBq6SR4a1o7yTyCtplm8lsgxIvimyhlzqWcjBbGfCTr3cQ9Ae1ywiyjN8wzGUy5RktwuZ11DKicmMepg0aPYFTb26DQBd4Wq/czVyMl8v32bxUB9PhGJU9G08m1Nxk86/1+bZo0e1xVncm25bWMuD47zm9wED+sFK8U0Xq0j019pKoV3VSg6BSY0oR3Ixm2ckj3yPMj3Fz3cy4nUn1ntXGQV6dixzIMnqm0WOWOvuk5OnBSQOk09ZA0HtKvHiW6BtPvwjnvz6HHoH6Eiok89OB/i4+QPrcFtKpGG9hIsK48KhDFNVzNpqWKSeZ50bHEwve4+DRzKzfxbcz2Y2jgnyWruWQTt0JZJL8HgPzI+ZHrcVeDG8Gw7D4RBi2MWy1tA01pqZrHH1u04j7SuEruK+XaZ1TX/jO7ttjy/gfb8IrKSnfz+EXHSlj07/AE9HH2NKu/iu4nWS8E2b5zFD0Lqe1wcZ9XnJNB+asvdNeZUVwleVHu2GdVFpMV3V9iWLebkGIsu1RHofPXSV1QSe/gOjPzVdG3Wu22inFJabdS0UDeQip4WxMHsaAF2kUeU5T+Z5mUkiGiiiLUyEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBQc0OBDgCCNCCORCiiAx92xbpWL5iye+YHHT2K9EF7qdreGjqneLR/YnH7po0729qw6vVlyTA7/JarvSVdpu9ulDtCSySNw5texwPTtDmnQ9QVtHVuts2xfHNr1iNJXNZSXelYfsfcms1fC7rwO+6jJ6t9o0K83imBQr51rVas+HM/R/nWVV5h0avx0dkvqWG2Y7aMQ2v2yHZjt9oaSrqH6RW68ygRuc88g18g0MUmumjxoHdHc/jUVtx3Wck2asmyTF5J75jjNXSu4Naqjb3yNb8Zn37Ry7QOqtxk2E33Br9V4zktCaetpHcL29WPaej2H5THDmD/TqFkhu17wcr56bZnn9f51kukFpr53anXoKaVx669GOP4J6tVDb3FK/lyS/WU9ylz58Jce8roOF3/QuVlLcpc/YzEIcOgIIIIXG8arLfeP3XaeGmq9oGzG3cHm+Ke5WeBnIt6ulgaOhHV0Y68y3uOJBLXc2kEFVl7ZVrCr7Ksux8zK25tKlrPUn48TI/YBvYXDEpKbDtpVVNXWQkRU9ycS+ehHQB/bJEPxm+I5DNWiraS4UsNdQ1MVRT1DGyxSxPDmSMcNQ5pHIgjtWprzfEr87tu8RWbM7hDiOXVT5sVq5A1r3Ek2yRx/sjf8ABE/Gb2fGHaDfYNjrotW9y/h5nw7er6Fnh2JOnlSrPZzPh/BnmikhmiqIWVEErJYpWh7HscC1zSNQQR1BCnXt956UIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAio7MdruzzBGvbkGSUzalo/5JAfPTk93A3Uj26BWLzDfCuVRx02C43FSsOoFXcT5yT1iJp4R7XH1LrCjOe5GG0jKGeogpYX1FTNHFFGNXySODWtHeSeQVssu3jtmWLB8NPdXXqqZqPM24CRuvjIdGD2ErEHKNoGZ5tMZcoyOsrxrqInv4YW/gxt0aPcvC6BSY2iXzM1cuBe7Lt7LPLtx0+MUFDYoTqBJp8In0/CcOEexpVnL/kmR5TUmryS+11zm11DqmYvA9TTyHsAXRcVKT4LvGnGHyoxvOFw0XDI0levZ7BfMlqxQ49Z6y5VBOnm6WF0hHr05D26K8mHbpGb3psdVldwpbDA7QmEf1xUaepp4W+1x9SSqRhvZnIx7kbw6kr0sewzK8wqBTYvjlwujydCaaEua31u+KPaVm3ie7JsoxjgmqrM++VTND525P843XwjGjPeCro0lHSUFO2koaWGmgYNGxQxhjGjwAACjyul+1GdUw5xHczzm8ebqMtvFFYoToXQs/rmo09TSGA/OKvXiG6nsjxfgmrbTPfqpmh87cpONmvhE3RnvBV4gorhKvUlzmcsjrW+2261UzaO10FNRwMGjYqeJsbB7GgBdjRRRcTIREQBERAEREAREQBERAEREAREQBQUUQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAUpHNTIgLW7etkNLtOxSSWhpo/wB0FtjdJb5ehkHUwOPc7s7naHvWAdaySGV8L2vjljcWuBBa5jgeYPaCCPYQtpywn3utmsWL5pDmNsgEdBknE+ZrRo1lY3Tj/HBD/XxrxelWGrVV9TW1bJfZ/bw4FPidtmvbR7y+G7Fthk2mYk6z32p48hsTWRVLnfGqYekc/ieXC774a/KCsjvZ7BIcRr3bS8RohHZrhNpcqaJujaSpeeUjR2RvPUdGvPc7lbDZTnlZszzm2ZXTOd5mCTzdbEP4WlfoJG+PL0h4tC2JXO3WTMscnttdFHXWq8UpY9vVssMjeo9hBB79F0w+pHH8PdvVf9SG5/R/Ziko4lbOnP5lz/Rmq9sWg6I6LXsVZbRMCrtnmZXTEq/ie6gm4YpSNPPQu5xye1pGvjqFTLovBeJqqVKbpz2NbGeblBwk4y3oyp3PttMkgbslyet4nMaXWOaR3MtA1dTa+ABczwDh2BZXLVZRVVba66nuVtqZKarpJWT088Z0dHI0gtcPEEBbINkW0Gn2m4FbMpZwNqpWeZromdIqlmgkb6ifSHg4L3mjOKO5pu1qP4o7utfx9D0eE3bqw9jPet3Z/BWaIi9UXIREQBERAEREAREQBERAEREAREQBQ07VFEAREQBERAEREAREQBERAEREAREQBERAEREAREQBFDVUlm21fAtn0Rdk2QQQ1GmraSI+dqH+qNvMes6BZScnkgVcundbvarHRPuN6uVLQUkY1fNUytjYPaSsWc43wL9X+cpMBssVshPJtZWgTTkd7Yx6DfbxKxGRZTkuWVhr8mvlbc5ydQ6plLg38FvRo8AApULSUtsthq5GWOc73GEWIPpMPo58gqhqBLzgpgfwnDid7G6eKx/zbeC2oZuH09VfnW2hfqPgluBgYR3OcDxu9rvYrcHXtUFKhQhDcjVts5WuJJcSS5x1JPU+tcrdVwNcBzKrTCdlOf565jscxyplpnHQ1co81Tj57tAfZqV0lJRW0wUu12i5qeKarnZS0kMk88h0ZFEwve4+DRzKybw/c8t0Pm6rO8jlqnDQupLcPNx+oyOHEfYGq+GK4DhuEweYxbHKK38tHSRx6yv/AApDq4+0qNO6it202UTEbEN2nablYZUVtvjsNI/n524kiQjvETfS9/Cr24dupbPbBwVOQy1OQ1TeZE581Tg+EbeZ+c4q9fRFFlcTl1GySR1LXZ7VZKVtDZrZS0NOwaCKnibG0exoC7eo6dU07yoriZIaE+CcIUUQBERAEREAREQBERAEREAREQBERAEREAREQEBxc9dPBRREAREQBERAEREAREQBERAFAqKIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIArbbwuGR5rsqvNK2EPq7dH9k6Q9okiBLgPWzjb7Vclcc8EdTDJTTNDo5mmN7T2tI0I9xXC6oRuqM6Mt0k0aVIKpBxfOaunRADkNQs7t1zKpMm2RW6GpfxVFlkfbHknmWs0Mf5jmj2LCq+Wl1pvNwtL26Giq5qYj8B5b/AELIzcrujo5sqsL3nhc2lrGN7jq9jj/M9y+a6L3DoYkqT/cmn9fsUGHy9ncavE9DfKweKqtFqz+lgAmo5BbqxwHN0T9TGT6n6j56xKfCtjO17H2ZRsyySzFnE+W3yyRDT+FjHGwj5zQtdxbxtDtOoBXfSu2VC9VWO6az71sf2NMWoqNZTXOjpmFZDbm2autGX1+EVU2lPe4fhFM0nkKmIEnTxdHr+IFYFzR3Fexgt/fiecWDI2OLRbrjBM8j+58QDx+IXKlw28dndU665nt7OfyIVtN0Ksai4my1FBrmuaHNOrTzB7wor7IeyCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIuvX3GgtVJJX3OtgpKaIavmnkDGNHiTyVkM83s8OsAko8Po5L/VjUeeJMNK09/ERxP8AYNPFbwhKbyijDeRfZzmsaXOIDWjUknQAeKtdnm8Zs5wkSU0Fw+zdwZy+DW9we1ru58vxG+8nwWJ2dba9oe0Evhvl9kjoXnlQ0n2mnA7i0c3/ADiVQ4doNAeXcpdO0W+bNXLgXaz3eY2lZeJaS3VrMfoH6jzNASJXN7nTH0vxeFWikkllkfNLI6SR51e97iXOPeSeZUziuM9VMjGMFlFGmee85GdVOGajkF27DYr3ktey2Y/aKu41b+kNNEXuHidPijxOgWQmA7o12rWxV20C6i3RHRxoaMiSc+DpPit9nF61rOrGC+JmUmzG8QySSMiijc+SQ8LGNaS5x7gBzJV2cE3X9pGYCOsudMzHre/n52uafPOb3thHpfjFqy2w/ZbgeCMb+5rHKWnnA0NU9vnah3rkdq72DQKq1Dndt7II3UeJafBN2nZrhfm6qroDfrgzQ/CLg0OY13eyL4g9up8VdaONkTGxxsaxjBo1rRoGjuA7FMiiynKbzkzYIiLUBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAFAnQajsUVB3QoDX/tdt7KPahlUDGFjRdZ3gH753F/Sri7oEog2gXem1P2+0kgfgzMPP3qhdsEsdVtRymeJ/Ex1zlAPq0H6QVXu6RSvdtCulU0t4IbS9rgTz9KVmmg+aV8jw15Y5FR6b+rPO0V/zaa4mWs0TZoXwvAIkaWEeBGn9K1o3GkFJcaujb0p6iWEcvuXlv8AQtmAI5esLXBkrQckvBbpobjVEad3nnr0WmuSjRf/AHfYk4tHNQ7/ALHhvj5LglgLmO06lp/QvQLNexS+bHcvAOWwpXHYbHMJrn3PDbFcZAQ6pttNK7XrqYmkr2lRmxri/wCCjEuI6n7EU/8AMVZr7jaTdS3pyfOl9D2FJ60E+oIiKQbhERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEUCdFJMx00L42TPiL2kB7NOJviNQRr6wgOhf8lsOLUDrpkV2prfSs/hJ3hvEe5o6uPgASsf8AP97mGDzlDs8svniNW/ZC4AhnrZCOZ9biPUriXvd4wLJ651zyWrv90qnfwtTdHkt8GgaBo8AAF5zt1TZA7rbrn+UZF3p+xjtlmzXaYkZbn+XZvU/Cspv1VXuB1Yx7tIo/wYxo1vsCpmR5Pas2n7qOx/r8Aug/0i9Sf1Jux13W33U/6SkUpXVNbEa6rMIy8BREgWbg3S9jPyrTc3eu5y/rXoWndh2LWirjrGYmat8R1a2sq5Z4yfFjjwn2hHdwGqzDbDcAzLaFWCkxGwVNfoeGScANgi/Dkdo0erXXwWRuBbnVpo/NV+0W9vuEo0caCgcY4B4OkPpv9nCsiqKiorZTR0Vuo4KSniGjIYIxGxo7g0AALnXCpdTlsjsNlHI8vH8Yx3FKBtsxqy0dtpW/wdNEGBx73Ec3HxOpXqKGoTiCit57zYa6KKkJ1UzeiAiiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIApZHtjY6Rx0awcRPcBzUypTapfRjezy/3YP4ZI6KSOI6/wkg4G/S4LlXrRt6Uqs90U2+7aayerFswayOuN4v9zux0/r2snqOXc6Rx/pWQG6BZy2DJL89nJ76ejY7T7kOe7+c1Y6OYGAN7GjRZn7vOOux7ZXazLHwTXMvuMgI0Okh9D8wNXyzRGlK6xT2r/am32vZ9yns6etWz4FxK2dtJQz1byA2GJ8hJ7mtJ/oWuCoLqqolqnDnPI+U/OcT/AErPTbDehYdmOR14fwvNC+nj8Xy+g36XLBLzQY0ADkBoFY6c3C9tRormTfi0vszfE3m4o6nmvBSSM4Wud3DVdws7l2LZbJLrdKK1xN1fW1MVO0d5e4N/pXhotyeSKpxzWRnzs7ozb8Cx2icBxQ2uladBoNfNN7FUK4aWnZSU0VLGNGQsbG31NGg/QuZffKMPZU4w4JI9VFasUgiIuhsEREAREQGOG+NvT3jdrocYGOY/bLxX3+ap44q6WRjYoYmt9McHMkueB71i6/yqG1cdNmOI/wAoqvrLxvKcZYy8beLVjMMvEzHsfhbI37maokfIfbwCJYeuOqvrW0oyoxc45tlRXuaiqtRewzZHlU9rA67MMRP+c1Q/3lO3yqe1P5Wy3E/ZVVX61hAToohy7cit+icuU1ukZwfvqW1Hs2XYp/K6n9a43eVU2qg8tl2Jfyqq/WsI+NSk6pyOh0Rymt0jNz99W2q9uy3Ev5VVfrUD5Vbav2bLsSH+c1X1lhEXdygnIrfojlNbpGbv76vtYHXZdiJ/zmq/WofvrG1f+9biP8qqv1rCNDonI6HRHKa3SM3h5VrakPj7KsTPqq6kf0qvtg3lDNqG2Xa9jGzaTZxjVFT3usMVRUQ1NQ+SKFrHPe5oJ01DWHryWuA9Fln5MnFfs5vFy36SPijxyxVdUHacmyylkLfoe9cq1rQp05SUeY6Uq9Wc1HW5zbCHLEfe632sg3d9oNswbF8Ss96dU2ltxq31s8rHROfK9rGgM72sJ596y3PILTNvtZa7L96DOatsvHDbauOzw89QG00TWOA+f5w+1V1hRjWqtTWaSJt5VlTh8L2l7XeVV2njpsrxX+WVK43eVV2qa8tl2J/yqp/WsJCeSlVxyK36JXcprdIzcHlVdqp67LsT/lVV+tZ87C84v+0zZFi20DJrZSW645Bb2V8lLSF5iia8ksALySfQ4Tz7StFkNNPXTx0FM0umqXtgiAGpL3kNaPeQt+mE4/DiWG2LFaZgZFZ7bTUDAOwRRNZ/Qq3EKNKjGKgsmybZ1KlRvWeeR7SIiqyeFDVcFdW0dto57hcKuGlpaaN00880gZHFG0auc5x5NAA1JK1s74G/xXZkK3ZlsMuk1HYHh0FxyCEmOe4Do6OmPIxwnoZOTnjpwt5u729vO4lqx8TjWrxoRzkXm3lvKH49sqyH9xWyq02/LbvRSll1q553ChpSNQYWOj5yyg/GIPC3TTUu1DbKDyq21UfG2XYkfVVVX61hGNGANaAAOg7lKeivYWFCEUmsypleVZPPPIze/fWNqI67K8U/llT+tRHlWNqBP/NXin8rqf1rB0jVXq3bN1LaHvH3vW0Rm04xSShlwvtRETFGe2OFvLz0unyQdG6guI7U7W2px1pRSRmFevN5RZk9s/8AKH7wW1TJqXEME2IY9drpVH0YIKipIYztfI4uDY2Dtc4gBZ6Yo/J5Mct8mawW2G+uga6vjtr3vpWSnq2Nz/SLRyGp681SOxXYVs52C4szF8AszYPOBrq2vm0fV10gHx5pNNT26NGjW66NAXjbwm8zs83drA2vyeoNdeaxjjbbJSvHwmrI5cR15RxA9ZHcuwBx5KnrShXmoUIZfVllTUqUXKtIu6+RkbHSPeGtaC5zidAB3k9isNtQ3393bZZNLb63Mhf7nFqHUNhjFY9ru50gIiafAv18Frd24b2+2PbtPNS5Bf3WuwPd9rsdsc6GlDewSH4058XnTuaFZR3QNboAOgHRTaOFpbar7kRal+91NGeubeVVvMr5IdneyWkgZzDKi917pHesxQgD2cZVrLn5STear3SfBbhjFta/4oprMHFnqMj3fSsWSNVKpsbShHdFEWVzWlvkZE1O/wA71FVK6X/hLbBxfIhtVI1o9QMZXXdv2b05Ov8AwrTj/R1J+yWP+pTiK6cnpdFeCNPa1Ok/EyLot/7enog1p2iU9SA8PPwi0UrtR9ySGDkqjtflJ95OiINZNitwA11E1oLNfbHI1Yo8SjxeCw7ai98V4GVWqr9zM5rH5VTPaZ7RkuyiwVzO00NfNTO9zxIFdbD/ACpGxq7GOHMcOyfHZHEB0kccddA3x1Y4P0+YtYLj2qVcZWFCf7cuw6xu60ec3h7O95bYRtVmho8G2n2Svrah3BFQyTfB6t7tNeFsEoa9x016A9Fc1am/Js4Mco3io8jngbJTYnaqmv1cNeGeXSCLTx9N59i2wg6Kmu6MLepqQeZZW1WVaGtJFid7neVq92zE7FerVj1Heq+93F1Gymqah0LWxMic98mrQSdDwDT75YrO8qln7f7UeO/lOo+qup5UnLBXbTcQw2KXVtos0tdK0HkJKmbhb7eGH6VhK4qytLSlOipTjm2Qbm5qRqtRexGcf76rnw67Ice/Kk/1EPlVc+PTZFjw/wBJz/VWDRGqlUnkVv0Tjyqt0jOf99Wz4ddkWPflOf6ilPlV8/7NkWO/lOo+qsGC5S8SxyKh0Ryqt0jOj99Yz8ddkOPflOo+qojyq+fHn/wR46P9Jz/VWCpOqmB7ljkVDojlVbpGdkXlWc2ZI34TsesT2ajiEd2naSO3TVh5qqLH5VyySSRsyXYxcadh+PJQXiOYj1NkYzX3rXZ1TQo7G36P1Mq7rLnNvuAeUC3as6mjo6nLKnGKqTQCO/Upp2a93nml0Q9rgshbZdbXeqCG6Wa40tfRVLeOGppZmyxSN72vaSCPUV8/7eXarlbE94HabsGyCG8YNfZW0XnA6ss88jnUNazta+Po1xHSRujh3noYtbDI5Z0n4kilfSzyqI3gahNQqD2K7YMU257PrftAxKVwhqgYqqlkIMtFUtA85BJp2tJ5Ho5pa4ciq79Sp5RcXkyyTUlmjE/et327lu87QaHBLDhluvsk1qjuNVLU1skJhc+R7Ws0a06+izi9qsi/yqWdD4uyLH/ypP8AUVht9PLf3Xbz2d10b+KGgrY7TF4NpomxuA+eH+9WQc7tV/QsqPsoucduRT1bqqpvVewzjd5VbPx02RY7+U5/qqX99W2hf3o8c/KVR9VYN9UXTkVv0fqacqrP9xnGfKs7QR12RY7+U6j6qi3yree/K2QY97LpP9RYMOGqk6JyK36I5VW6RnZ++uZz/eesP5Wn+opD5V3OteWx6wflWf6iwUJ7VLr4JyK36P1M8qrdIzvb5VzOe3Y7YfZdp/qKb99czf8AvPWL8rT/AFFggD3KbqnIrfo/UcqrdIzub5VrNieex6xaf+bT/UWVu6NvD5BvJYZecvvOIUdhit1z+x0DKerfOJiImve4lzRppxtC0yrb95PLGf3ObreOVT4+GW/VVbdn8uofM5jD+JGxQ763o0aWcI5PMk2lapUqZSezIyNqqmGjppqypeGQwRulkcejWtGpPuBWuqo8qploqJRSbIrI+ASOETnXWYFzNTwk/a+pGhWZO9Flgwrd42g5CHlksVhqqeEg6ESzt8zHp86QLSMAI2tjHRoDR7Fph9tTrRlKosza9rTpySg8jOp3lV82HTY9YvytP+zUh8q1nGv/ADPWH8rT/s1gs7mpVYcht+j9SJyqt0jOweVbzXt2O2L8rT/s1KfKt5x2bHbEPXdp/qLBVSrHIrfo/UcqrdIzsHlWs47djti/K0/1FI7yred6+jsesHtus5/3FgsoEapyK36P1HKq3SM6m+Vczv5Wx2wH1Xacf7i79u8q9fGyH7L7FKGRhA0+C3x7SO/48RWAwaojqnIbd/t+pjlVZfuNmmPeVR2W1j2MybZtlNrDjo6Smlp6trR36cTHH2BXu2f75+7dtGmhorPtLoaGumIDKS7sfQSFx7AZQGOPgHFaX1HXUFpGoPYVznhtGXy5o6Rvqqe3afQWx7JGNkje1zHgOa5p1BB6EHtCmWm/dx3xtpuwG5U9Aa2pyDES4NqbHVTlwjZrzdSvdr5l4GvIeg7tHyhtxwfN8b2j4jas4xG4trbReKdtTTTDkeE9WuHyXNOrXNPMEEKpubSds9u1cSxoXEa62bzq7Uc2h2cbN8nz6aKOYY9aaq4tikcWtlfHGXMjJHMcTgG+1YDt8qxmzQBLscsROnZd5x/6av8A+UZzJuMbtFzs8cnDPlFxpLSwa8yzj89L7OCEj2rUsSpthbU6tNyqLPaRbuvOnNRg8jOs+VazMf2m7J+WJv2ai3yreYfK2M2U+q8zfslggim8it+j9SLyqt0jPH99ay49NjNmH+mpv2SlPlWcy7Njdk/LM37JYIg6KYHVOQ2/R+o5VW6RnZ++sZp/ebsf5Ym/ZqB8qxmo/tOWP8sT/s1gooE9icit+j9Ryqt0jOv99czEddjVkPqvE37NP31zMf7zNl/LM37JYIk6qCxyK36P1HKq3SM8R5V3LvlbF7P7L1N+yUR5VzK+3YxaPy1L+yWBqA6LKsbfo/UcqrdI2EYt5T7Msqya0YvQbFrUaq8XCnt8P/HUvJ8sjWA/2L77VbBxrp6WmvgtM+47h/7st6HCad8fFBaqmW8zajUAU8TnN1/yhjW5gdFVYhTp0pqNNZbCws5zqRcpvMiiIoBLCIiAIiIAiIgIEgKwO9fljaW0WrD4JftlbKa6oaOojj5MB9biT81X6mljhjfNK8MjjaXPc46BrRzJPsWCe1DL5c9ze5ZEHONM+TzNG0/Jp2cme/m4+Ll5LTK/VrYewi/iqbO5bX6d5HuZ6sMuJ0MPxufMcntmN04JNfUsieR8mPq93saHFZ801NBR08VJTRhkMDGxRtHRrWjQD3BY77qeCuaK7P6+DQHWioOIfxrx9DfxlkYueheHu1snczXxVPot3jtfZkaWlPUi5cSxe9ZkAgxu1YtE/wC2XCpNVK3X+CiHL3vcPxVjC6I6clcjbdlP7rtoVxqYZOOkoCKCm0PItjJ4nD1vLj7lQPm/BeA0jv1f4lUqRfwr4V2LZ5vN95AuZe1qNnSMKuLu/wCM/Z/ajanPj4oLZx3CXly+1j0Pzy1UKY1kxur4oaGw3LLaiPR9ymFLTkjn5qP4x9rzp81b6N2rvsSpw5k9Z9i2/XJd5zoUteqkX0HIKKIvtpfBERAEREAUDqRoO3korzckvNPjmPXPIasgQWujnrZSfuYo3PP0NRLPYNxpi3tMq/dnvIbQb22QPjZeZKCFwOo83TNbA3T+LKtC7qu3crlUXq41d5q3Ez3Golq5Sfu5Hl5+ly6rh2r10YakVHgeclLWk5EhBXJS0VbcKmOit9HUVVTM7hjhgidJI89dGtaCSfUFIslfJ44wci3oLFWObrFYaGtur+XaIvNN/OmHuWlWXs4OfA2hHXko8THmTE8uiOkmJX1p++tlQP8AcXH+5vJx8bGbwP8AR8/1V9AHPvPvT2n3qq96Po+f8FhyBdI+f/8Ac3kv/hq8fk+b6qiMbyY9MavB/wBHzfVW/wD9p96e0+9Pej6Pn/A5AukaAhi2Unpi16Pqt0/1FH9yeWEf/Cl6/J0/1Fv859596EnvPvT3o+j5/wAD3eul5Hz+vxrJYzpJjV3b67fMP91bDvJVYNXWyyZ9mV0tlTSSVlXR2uD4RA6NxZEx0j9A4A6ayt9yzxOp+Ufep2nQLjXv3WpuGrln1nSlZqlNTzzOGvq4LbRVFxqnhsNLE+eRx6BrGlxPuC0HZVfZ8rym9ZTUkulvFxqa9xPfLK5/+8t0u9PlZwrd12hZCx/BLHYammhOvMSzt8yzT50gWkhrQxoY3o0aD2KVhUPhlM438vijElI7CocKnd0UqtSvLk7s+KOzXeD2e455vjZNf6WeYEajzUDvPv8AzYit4bTrzPbzWqryZuFHIN4GpymSPWHF7LUTtcR0mnIhZ7eEyrappoqLE561VR4ItrGOVNviyZeFnGc4ps4xeuzLNb3T2q0W6Pzk9TO7kO5rQObnE8g0AkkgAKmdtm3PAdguISZZnNy4OPijoaCEh1VXzAa+biYTz7NXHRrRzJC1Hbw+8ntD3isl+ymU1Zo7NSPJtdjp5D8Go29OI9POykdZHDXsaGjkuVrZyuHm9kePob3FzGisltZcDeu308r2/wBRPimNMqbFgkcnoURdpUXLQ8pKotOnDrzEQJaORcXHpjOTqdSoBF6CnTjRiowWSKac5VJa0t5KeqgSACSdAO0rv2Wx3jJbvSWHHrXVXK5V8ogpaSliMks0h6Na0cyf/wDp5LZfupeT8sGzv4FtA2z09Le8obwz0toOktFbH9QX9k8w7z6DT8UOIDlzr3MLeOc/A6UaE6zyiWO3S9wO8bTW0W0PbFBV2fFHcM9JajrFWXRvUOd2wwnv+O8dOEEOOzDH8dsWKWakx3GrRSWu10EQhpaSkiEcULB2NaOQ/pPMr0tVBeeuLmdzLOW7gXNGhGislvKI20bUbNsY2Z33aNemCWO005dBTcXC6qqXHhhhB73PLRr2DU9i0pbRNoGV7UcxuedZrcnV12usvnJn9GRtHJsUbfkxsHJre7xJJzV8qHtQmqLzi+x+gqiKejhN9uLGu5OleXR07XfgtErvnhYEP6q4w6iqdLXe9/Qrb2q51NRbkQ4tOqgXqU9VI8hoLidA0an1BT2RDkLmgFznAAdpOiqzF9kW1TN2tkw/Zvk15jfzbJR2uZ8ZHfx8PD9K2Sbm25jgOBYJZdoG0PG6K+ZneaaO4AV8QmhtUcjQ6OKKN3o+cDSC6Qgu4tQNAFlwxrY2NijaGMaA1rWjQAdwCqq2JRhJxgsyfTsXJZzeRpdody/eluUQnp9i98jaSW6VD4IXfivkB09i7X9Q7vVjrsduP8tpP2q3M8u5OXcFH951eCO3IKfFmly4bmO9HbmsdNsXv0nHqB8HdBMR6+CQ6e1URfdim2bGifs/sny+haNdXy2ao4eR+6DSPpW9rl3BR1Pefetlik/3RMOwjzM+fGobJRzGmrYpKeZvIxzNMbx812hUhkaOq36ZJguE5jA6ly3D7LeoXjQsuFBFUA/jtKsPnXk8d17NeOakw6qxiqfqfPWGtfTt1/xT+OL3NC7wxOm/mTRylYTXystl5K7C2UWzfLdoMsOkt6uzLbC8jrDTR6nTw85K78VZwnoqD2F7H7JsI2Y2nZjYK+eupbWZ3mrqGNbLO+WV0jnODeWvpacu4KuK2qgoKSavqnhkNNG6aRx7GtBcT7gVVXFT2tVyXOT6MPZ01FmnPfgyr91e9Bm1RHJxQ2ueCzxc+gp4WtcPxy9WKXr5lkU2XZhfcsqHEyXq51VwcT/hZnPH0ELx16anDUhGPBFFOWvNyCRQT1LxFTQSzSHUhkUZe4gdeQBKgT4rLfyZeLG9bfq3IXt1ix6w1EupH8JO5sTR7uNK0/ZU3PgZpw9pNQ4mJL7fcR8a3Vg9dPIP6FJ8AuH/AHfV/wAnf+pfQN5iH+4x/iD9SeZh/uMf4g/Uqr3p/j5/wWHu/wDy8j5+xbbkeltrD6qaT9Skmp6mlbxVVLPC0dXSROYB7SAvoJDIxyEbPxQuvWWy23GF1PcLdS1UTtNY5oGPadOmoIIRYoueHn/Bj3f/AJeR8/sZa8cTSHDvB1XJoVuf2n7nu75tTt9VDdNndstNxmafN3WzQMo6qJ5+XrGA1/qe1wPctS+2vZVediO0297Nb7UMqZrVK0w1TGcLaqmkaHxSgdnE0jUanRwcNTpqp1tdwudi2Mi1radDa9xRPCg5KBOqeIUlnAy+8mvtUrMU2zz7OKmd5teZ0jw2PU8LK6naZI36dhMYkafm9y2g3Ovp7Tbqq61Tw2CjgfUyHuYxpcfoC0tbp0tRDvK7Nn0r3Necgp2EtOhLCHBw9XCStqe9jl37h92/aBfmPDJTZZqGA68/O1OkDNPbJ9CpL+lncRS58i0tKmVFt8xpiyS/VGUZHdsnq3l013r6mvkJ6l0srn/7y85S6BoDW9G8h6lE9Ar3JbipIqaOCefXzEEsnDzPm43O09egXGDoth/kqMSjNpz/ADaeIO8/U0doi4m6jSNjpn9f8az3LhcVVQpubWZ2o0/bTUDXoaSr/wCx1H8S/wDUuN1LV/8AZKj+Kd+pfQP8DpP+yw/xbf1J8DpP+yw/xbf1Kt96Lo+f8E33f/l5Hz6mkq/+yT/xTv1KU01UOtLMP8k79S+gz4JS9lND/Fj9SkdRUZPOjgPrib+pPen+Pn/Bn3f/AJeR8+wgqB1ppv4t36lMGSjrDJ/Fu/UvoHFHRjpSQD1RN/UoOoKF3xqKnPrib+pPen+Pn/Bj3f8A5eR8/ToahzHeap5nO0OgEbjqezsW9rYvjDcK2RYZibWcJtVhoaZ4009NsLeL87VVULfQN+LQ0w/yLf1LsdAol1d8pSWWWRIt7b2DbzzMTPKX5d9g936nxuOXhlyW+UtMW9roYQ6d/wBMbB7Vqrd1WdnlTssNXmGD4PFJ6Nut1TdZWg/LnkEbNfmwu96wUcFb4fDUoLr2ldeS1qz6iU81Dh7lFRc/zbS8DXhBd7lNI5xu5dQefgVL6gfcVvA2B7N7ThOxXCMWqbVSyVFDZKUTulp2Od557BJJzI1+M9yuA2x2RvSzUA9VNH+pVEsTjGTWr5lgrBtZ6x8/p17j7imunY73FfQKLRadOVrox/m7P1KBslmd8a00R9dMz9S196Lo+f8ABn3e+l5Hz8mohDuB0rA7uLgD7lyNP0rfZetm2zzJInwZDgeO3OOQAObWWuCYEDprxNPTVY27evJ5bH84x6uuGyywwYflEUTpKQUbnNoaqQDURSwklrA7pxs4S0nUhwGh7U8TpyeUlkc52M0s4vM1TouappZqOplo6qJ0U0D3RSsd1Y9p0c0+IIIXFwlWZAILYP5LDaZcagZhsirp/OUlIyO/W5rjzjL3eaqGjwJ807TvLj2rXzwlZZeTK863eRqSxxDTjFeHgdD9tp9PpUS9ipUJJkm2k41Y5FyvKs5bxXDZ/gkcoHmoq28zs17SWwxkj2S/SsAS9v3Q96+gSqtturJBLWW+mneBwh0sLXkDu1I8VwGwWE9bJbz/AJrH9VVlC/jRpqGru6ydWs3Vm56xoCD2ntCj6lv9FhsTfi2W3j1Usf6lE2SynkbPQ/yZn6l296Lo+f8ABz93vpeRoB5dNRqpgNFsP8qZdLXa8awXD7bRUdPLcLhVXOfzMDGPMcMYjZqQNdOKY8vDwWvAnRWNvU9vTU8ssyHWp+ym4Z5gnRSOKmJ1UOAu5DtXXI5HGZI28nPaD3E6JxsPR7fetsnk8NnFrs+7VbbvdLVS1E+S3Ksuus8DHkR8Yhj04geXDDr85ZMDGMaH/V61/wAii+qq2piMac3HVzy6ydCyc4qWe80BF7Pu2+9RD2H5bfet/wAMbx4dLDbR/mkf1U/c3jp/+QW0/wCZx/VXP3ouj5/wb+730vI1x+SsxcV+0nMsxfG1zbTZoqCN33MlRNxHT5sB962YLq0Vtt9uDhQUFNTB+hcIYWs4tOmvCBqu0q65r8oqOeWRMoUvYw1QiIuB2CIoICKIiAKB5qK61xuFJaqGe5V8zYqemjdLK8/JaBzWJSUE5SeSQLYbw+YOsOHHH6Gbgrr5rCeE+kymH9kPt5N9p7ljDjWJXDKb9Q47bGfb62URg6cmN6uefBrQT7FVueZRWZvkdVfavVrHnzdPETyihb8Vv9J8SVe3YLs4/c3a3ZVdafhuVzjAhY4c4Kc8x6i7kT4aeK+RylU0vxvKH6MefhFfeT3dvUQ5J1p9RcnHbFb8ZslDj9rjDKWghbDGO06Dm4+JOpPiVTe13NG4RhNZXQyhtfVg0lENefnXA+l81urvYFWvJoJJAGnPXsWIu2nPDnWWSNo5C61WsupqTQ8pDr6cvziOXgAvcaSYpDBcP1aWyUlqxXDr7l55HatP2cMkW5LCeepJ7z1KlLF2ODs0UCxfFUyrcSNttVXebjS2i3RGSprZmQRNHa9x0Hs5rOjGLBSYtj1vx6hA8zQQNhB0+MQPScfEnU+1WG3a8BNTXTZ7cYftVKXU9AHDk6UjR8g/BB4R4k9yyNX1fQnC3bW0ryoviqbv+1er8kidaUtVOb5wiIvcEwIiIAiIgCsjvqZWcQ3Ys9ro5THNW277FwkHQl9S9sPL5r3K9ywv8qPlJtux3G8Tjl0ffb+2V7e10VNE559nG+P6FItYa9aK6zjcS1KUn1GsU6a6DoOigolQXqCgJSFnv5KfEWT3vPs7lj9KkpqO0QOI6GRzpZAPYyNYFK6+yPeg2ybDbFWY5s1yCitlFX1ZragPtlPO98pY1mpfI0nQNYAB0HPvUe5pyq0nCG9nWhONOopS5jdii1Bu8oLvXP8A7Y1I31WOi/Zo3ygm9a3rtGpHeux0X7NVHuytxX53Fny6nwZt8RahT5QTesd/bFpB6rHRfs1D98A3rO3aPTfkSi/Zp7srcV+dw5dT4M29qB6LUKfKA71f98el/IlF+zXBL5QHeuaC7/hJpwB/9Fo/2ae7K3FfncOXU+DNwAGqmHJW33br1mmUbDMMynaHdPh9/vdrjuVXN5hkIPntXsaGMAA0Y5o6K5XCoEo6rceBMi9ZZmJflL8oNl3eIcfjmDZcjvtJSubrzdFEHzu+mNnvWqojQrPPyqWVifJsDweKT/kVDV3aZvjK9sTCfZHJ71ga4c+S9Bh8dS3XXtKa8lnWfUSHooKZSE6dVMzyIxsk8lViraXCM3zWVnp3G6U9tjcR8iCLjd+dN9CvXvRb3eE7u1pdbIhFe8zq4uKhs0cugiBHKapcOccfcPjP6N7XDBLCN8qfYnu62vZRsgpy3KbjLVV94vdTD6FA+WQgR07DyklEbWem4cLewOPTGi43S53u41N4vNxqa+vrZXT1NVUyullmkPV73uJLie8qsVn7evKpV3cOJO5T7GkoU95Um0vafnG13KqnM8/v090uVR6LS70YqePXURQxjlHGOxo9ZJOpVIu6qZSvVnkorJbiFtbzZBV3sf2J7Q9ueVx4ns/sjquUcLqurkJZS0MRP9kmk6NHXQDVztNGgq6W61uXZzvA1UOR3f4RjuEMfrJdJItJq0A82UjHDR3cZT6DfvjyW1bZrsuwXZFi1Nh2z/H6e1W2n9JwYNZJ5NOcssh9KR57XOPgNAAFBur+NH4Y7ZEqhaSq7ZbEW43a90zZ7u6Wds1uiZd8qqouG4X2oiAldr1jhbz8zFr2Dm75RPLS+HCpkVFOpKpLWk82W0IRgtWO4hwhSuGgJU6g7oVobGm7fcvkt93oc7mfKHtoquG3x6a6NbDTxt4efceL2qw7uZV6t8u1T2fed2h004IM92FW0kaasmhjkH85WUJ1K9XQSVKOXBHnquftJdrJeFRLdQQNOYI59FFF1NNxuk3fd5bZRtoxS1Mx/JKGjvkdJFHWWOpnbHV08rWgODWOIMjNRye3UEadDyV5NCBqQQvn6aSHMkBIew8THA6Fp7weoKr3Ftve2vCovMYttYyu3xf3Jl0lfH+JIXN+hVFTC83nTl4ljC/yWU0byE0PctO1v37N6q3ABm1aeoAAGlVbaOX9MWuvtVb2Tymm8TbBw3W24heBy5zW6SB3vikA5+pR3hlZbmjsr+k96ZtS0TQ9y102LyrWSxOAyfYzbahunN1vvEkTvYJI3D6VdzDPKbbBL86ODKbXk2LyuA4n1FGKqBp/DgLnaeJYFwnZV4ftOsbqjLnMu9D3IG96pPZ7ta2a7Vrd9lNnebWm/QgavbSVAMsX4cZ0ew/hAKrlGcXF5M7pprNBWo3q8vfg27rtAyKF4ZNHZJ6WA6/ws48yzTx1kV11h/5TvK22fYLbcZjmLZsiv9PGWg/GhgY+Z/s4mx+9dbaGvWjHrOdeWpTk+o1ZhoY0Mb0aNB7FNryUEXqjz4WxryVOLCHE87zWSH0q240trieR8mGIyPH40zfctcq2/eT8xQYvuuYvO9nDNf5au8y8uvnZnBn+rYxV+JT1aOXEmWMc6ufAyL4VAghTovPlySIpiOXRSoAtTXlJ7jR1+85PT0gb5y34/bqapI7ZD52Tn48EjFtQynJrHhuO3HKsluUNBarVTvqqypldo2OJo1J9fYB1JIA6rRxte2h1e1jadku0WtY+N1+uMtVHE/rFBrwwx/NjawesFWmF026jnzJEC/klBRKRB71NqO9SIrtlWZF7guNVGS70WKSxMJiszKu6TuA5BscDmDX1vkYFmB5TzKfsPsHtWMxycMmQ5BTxubr8aKCN8zvZxCNUH5K7ZvJFRZftaraZwFQ+OxW97h8ZrNJagj5xib80qmfKq5X8LzzBsKjl1bbbXU3OVg7HzyiNhPzYXe9VUn7W+iuj/wDpPivZ2rfEwY0CiRqoahNQrYrhw9y23+TnxYY7uxWm4uj4ZchuVddHkjm5vnPMsPq4IW+9akVfzCt9veIwDFbXheLZXbqS02amZSUcBs1M/giaNAC4t1ce8nmSol5RnXp6kCRa1Y0Z60jcei1GHyhO9OR/8cWwf6CpfqqT98G3qf8Ax5bvyFSfUVX7rrcV+dxYcvp8GbdlAgdy1Fjyg29SP+vdu/IVJ9RRHlCd6gdc4th9dipfqp7srcV+dw5fT4M25aeBUFqP/fC96g9M2tX5Cpvqqstiu+lvRbSdr+HYLWZrb30l6vNNTVTY7JTNJp+Lil0IbqPQa7n2LDw2rFNtrZ+cDKvqbaSTNnygehUevMKWSSOGN00rg2OMF7yegaOZPuVeTDUBv4ZOcl3n8ta2XjiswpbRHz6eahaXAfPkese3c9dFUu0vKZM22i5TmD3lxvV5ra4O16tfM4t/N4VTJPcvW0oalOMeCPOVJa83IlVTbMcYfm20rFMQZGX/AGZvdDROaO1j52B/5vEqYJAWRPk/sVblG9FjM00XHBYoKy7ycujo4SyM/jytWtaWpTlLgjalHWko8Tb+xjI2iONoa1vJoHQAdAooi8oehItUylB0UdUBFSnqPWFHUBWc3rNuNq2FbIbvkL66Fl8uEElBYqUuHHNVvaQHhvUtjB43HoA0DqQtoQdSSjHezWclCLkzUDtUuFFddp+YXO3Maylqr/cZoQ3oGOqZCNPDRUsocRJJc8uceZcerj2n2qBJK9clksjzre3MjqFmv5LGwOrdq2X5K6MllssEdIH9gfUVDTp+LCVhPodOS2meTJ2dTYtsQuGb1sBjqMyujp4S4aE0lOPNRn1F/niPWoV/NQoPr2Em0i5VV1GYGicKii84XZLwlQU6lcNeXfyQGqvymGWNvW8HS49E/VmOWCmp3DXpLO98zvzTGsSD1Vzt5nLv3c7fs+yVs3nYp75UQQOB1HmYD5lmnhpGFbBeroQ9nSjHqPP1Z69ST6wp2ankwcTtPRHeewKQnRVnsTxl2a7Y8IxMRGRt0v8AQwSN011i8810mvhwNctpPVTbNUtZ5G6jY5iLME2UYhhzIhG60WSjpZG/4RsTeM+1xcfaqx0KiNOenTXkorycm5NtnoUtVZIl4VMiLBkIiIAoE6BRRAQGvaooiAIiICB5LHvbttLbdKx2F2afipKR4NbIw8pZh/BjvDe3vd6lXe2TaN+5W1Gy2eoAu9cwgOaedPEeRf4OPRvv7FYfBcFuOc3+O2U3EyBpElXU6aiKPXmfFx6Adp9RXzzS3Gp16iwaw2zlsll//P8A9uC2cTlUbfwoqnYxs7OW3QXy60+tot7wdHDlUTDmGDvA6n2DtWTAAHQLoWaz27H7ZT2e1U7YKWlYGRsH0kntJPMnvXDk+S27E7LUXu5P+1wt0YwfGlkPxWN8Sf1r0eC4XQ0esWqjWeWc5fnMubx5zaMVBFBbeM7djmPnHbZPw3K7MLXuafShp+jneBd8Ue09ixhMHCNGjTRVNk16uGUXmqvlzk456l2pA+KxvyWN8AOQ/wD2vFfF3hfIdIMaljN7Kt+xbIrq9XvfhzESo9d5nQMfgV6uK4xX5bf6OwW5ms1XIGl2nKNnVzz4Aan6O1dV0WmpWTmxDZ0cQshvV0g4btdGNc5rh6UEPVsfgTyLvYOxddHcJnjV4qP7Ftk+rh2vcvHmNIUvaSyK+sVkoMds9JZLZF5uloohFGO06dSfEnUnxK76Ivu8IRpxUILJLYixSy2IIiLYBERAEREAWs7yp2Uiu2o4fh8curbRY5a6RuvSSpm4R+bB9K2YHpyWmffeyz91+9DnFXHLxwWyphs8PPkG08TWOA/ynnPerDDI61bPgiHfSypZcSxpOqKHF4KI5r0BTBF72CYdc9oWbWHBLLJFHX5BcIbdTyTa+bY+R2nE7hBPCOp0HQLKw+S1246nhzrCCO/ztUP/AElxqV6dJ5TeR1p0Zz2xWZhqizJ/ettuf/jnCP42q/ZKYeS124HrneDj/K1X7Jc+WW/TR05NV6JhsOiisyR5LbbeOue4R/GVX7JD5Lbbef8Ar5hH49V+zTldv00OTVeiYakrkoLXUXy40lkowTUXGoio4gPu5XhjfpcFmOPJZ7bT1z/CR6nVX7NVfsi8m1tHwjajimZZVmWK3C1WO7U9xqqamFR5yVsTuNobxMA+OG9StZXlBJ5SRlWtVvJxM/cbstNjWO2vHKMAQWqigoYgB8iKNrB9DV6J5DVQB7+1HvZGx0kjgGMHE4noAOq849rLvcahN/8Ayv8AdNvQ5LBG/ihsVNR2dnPoY4hI/wDPmd7ljp1VU7VMrfnO03LMxe4u+zN7raxp+8dM7g/NDVSy9VShqU4x4I89OWvNyJHHTVcbhquQ81IRqtjCJANFyN6qTQjsU7e9EgyZdq2Vs1suVJc4IaaWSjnjqGR1MLZonuY4OAfG70XtJHNp5EagrrAaqYHRZfAwbpt1/b5jG33ZrRXyzxUtvu1tjjpLvaISAKGYN0HA3+4uA1Yemmo6tIV4loz2MbZ8y2F51RZ3hlUBPD9qq6OVx8xX0xIL4JQOw6ah3VrgHDpz3I7GNsmGbdMEoc7wus44KgBlVSPcPP0NQAOOCVo6OGvXo4EOGoIXn7y1dCWtH5WXNtcKqtV7yu0RFBJQREQGEXlD91295/T0+2nZ9a5K67WmkFJeqCnjLpqmkYSY542jm98erg5o1JYQR8TQ60HciW9x0Pr7l9BisLtm3KdhG2mpnvN1x6SxX6oJdJdrK5tPLK77qVmhjlPeXN4vFWtpiCpRVOpu4lfc2bqS14bzTaApg3vWc+YeStzajkkkwLalZrlCObIrtSSUkvq44+NpPjoFaW++T83pbI53mcGo7rGNTx2+7QP19jyx30Kzjd0J7pIhStqsd8THRR4Vcu8bsu8NYCPspsXy5gJ0Dora+cE+uPiVKXTZ/n9jMgvOC5FQGIcUnwm1VEYYO8ks0C6qpGW5nNwa3op/hUCFyTMfTu4Khj4Xd0jSw/SuIEEatcCO8LY03DhCh0UylPVAzvWO+3nGrtT3/HbvWWu50jg+Csop3QzxkdrXtII9XRbMdx/fRuG12pGynapUxOyyKF0tsubYxGLpExur2SNHITtaC7UAB7QToC066v1UGBZlcdnmb2HObROYaqxXGnr2OHaI3guafBzOJpHaHFRrmhG4g09/MdqFaVGWa3G+rULW95VXKTVZtgmFMkBbbrZV3SRo7HTytjZr82F3vWxmjrYLhRwXClOsNTEyaM9NWuaHD6CFp+388u/dbvRZb5uTigsjaWyxc+nmYgX/AOskeqnDYZ18+CLK9llSy4mPygXdyHopV6AqCD+JzHBpAdodD4raDs43/wDdcwHAMbwinrco83YbVS24OFjfo4xRNaXfG7SCfatX6aBRq9vC4yU+Y60q0qLbibZ2+Un3YXD/AN6ZKPXYpf1ofKT7sY6XLJj6rHL+tamm6KOmqj+7aHX4nbl1bqNsMvlK92SOIyNrcokcCBwNsb+I+PNwH0qisy8qdsxoIZGYJs7yS9VGmkclwfFQwa950dI/T5oK1p6FSuC2jh1unm833mHe1mXl29b2m1zeDLbfldygt1gikEsVktrXR03GOjpCSXTOHYXHQHmGgqy5OqEaIpsIRprViskRZSlJ5yeYXu4ThuR7Q8rteFYnb31t2vFSylpYR0LndXOPYxoBc49jQSunj2OX7Lb3R43jFnq7rdbhIIaWjpYzJLK89gA+knkBzJAW2Hcy3P6Hd9srsszAU1dnl2gDJ5I/TitkB0JpoXfKcTpxyDqQAPRHOPc3MbeOb38yO1ChKtLqL07GtmFo2M7MbBs4srhJFZqQRyz8OhqahxLppj4ueXHwBA7Fqs3+8o/dPvTZWxkvHDZIqO0R+HmoGvePx5XrcNI9kbDJI4NYwFziegA5laGNpmUSZvtHyrMpXcRvd6ra4H72SZxb+bwhV2GJzqyqP8zJt9lGnGCKaRFM0dquyryA6LkbyVwNhmw7Lt4DNH4NhlXbqWtjoZa981e97IWxxloIJY1x1JeAOSv8PJfbwPblODD/AD2p/YLjO4pU3qzlkzpCjOazis0YhqPMdqy+Hkvtv3blmD/yyp/YqP719t8/8W4N/K6n9itOV0Okjfk1XomII6KBWYA8l/t67cuwf+V1P7FP3r3b0f8Arhg4/wA6qf2Kxyuh0kOTVeiYfg6LKHycmJDI95OkvEsXHFjVprLjzHISOaIGf7Vx9iqAeS728duZ4P8Ayiq/ZLJ3cq3Tcs3cKrKrpmt3slxrb3HS09K+2ukd5qKMyOeHGRrernM6fcrhc3dJ0pKEs20daNvUVSLkthlNwhW93hcq/cPsMzvKWycElBYKx0J10+2uiLI/z3tVw1i35R/K249u011obLwy5JdaK2tbrzcxr/Pv/Nh+lU1vDXqxj1lpWlqU3LqNS7W+bY2P7kBvuUT4IeaL1TPPJEiyI3MNv+z3d0y3IMuzWyXy5VNwt8duom22OFwjYZOOVzjI9vM8MYGmvQrHhyA6LSpTVWLhLczeEnTlrLmNoQ8qRsM054VnA/zWlP8A66j++kbCe3C85/klL+3WrslAonu634PxJHLqxtF/fSNhH/gvOv5JSft1LL5UjYcGvdDhOcPcGktDqalaHO7Br586etav0B0WPdtvwfiOXVjPjPfKoXeppZabZnsugoZnAhlZe6zz5Ye8QQgA+16wt2lbUc+2uZLJlm0TJaq83F7eBjpSGxwR66+bijbo2NmvY0eJ1PNUw4qQg9VJpW9Kj+nHI4zrVKvzsiOaKDVXeyLYntJ245C3HdnWOTXBzXAVVY70KSjaflzTH0WjwGrj2NK6ykorN7jRJy2In2I7Icj247R7Ts8xyN7X10nHWVXDq2ipGkednd+C08h2uLR2rd3imM2jDMatWJY/StprbZqOKhpIgPixRtDW6+Og1J7yVazdi3ZMS3bcQdbbfK255Fcwx94vDo+F07h0ijHPghbqeFvUklztSeV5wvPX11yiWUdyLm1oexjnLeyZERQSUFTW0vKoMG2e5LmVQ8Njslpq68k98cTnAe8AKpVjh5QbLP3L7rWUwMfwzX6Sks0eh6+emaX/AOrY9dKMPaVIx4s0qS1IORqCfUTVb31VS4umncZZCepe46uPvJUqgOZ1UV6w88gRqsoPJw4X+6jeWor1LGHQYtaqu6HUchI4CCP6ZXH2LF9bFPJTYcYrHnu0CaAf13WUtnp5COekTHSygeGssfuUS9l7OhJki2jr1UjPkDQaKKIvNF4EREAREQBERAERQQDVUtn+dUOFWh1Q7hlrpwW0lPrze77p3c0dp9nUrmzjNbZhVodcKwiSd4LaamB0dM/+ho7T2etY8U/7ptp2U8yamtqjq49I4Ix/NY3/AP3UleQ0l0ieHpWVl8VeexJbdXPn7eC7316yllsOvbrRkO0TJXRMc+qrax/naid/xY29rnHsaOgHqAWSuIYjasMtDLTa49TydPMR6cz/ALo/0DsCkw7DbVhlrFBQMD5pNHVFQR6Uzu89wHYOxe65waC5zgABqSToAFto1o4sJg7m6+KvLe9+WfMnx4v8aMctpLU1MFFTSVdVMyKGFhkkkedA1o6krGjaXm9Tm121iLo7ZSEtpYjy175HD7o/QOXeql2qbRP3QyusFmlP2Nhf9tkaf+UvH+4OzvPPuVtXM15aLxWmelCvpvD7R/018zX7mubsXm+pI1nt2Hnvh5dFwOh8F6T2eCqbZ5gNTm93DHh0dtpnB1XMOXLsY374/QOa8TZW1a+rRt6CzlJ5JfnmcXDPYj29iWzZt6r25beafWgopP61jeOU8w+Vp2tafefUVkMuvRUVLbqSGhoYGQ08DBHFGwaBrR0AXYX3/AsHpYLaKhDbLfJ8X6LcvU7wgoLJBERXJuEREAREQBERAde4VsNuoai4VDg2KlifPI4nkGsaXE+4LQZlN/qMrym9ZTVOLprxcamveT2mWVz/APeW6Hexyw4Vu4bQ7/HIWSssVRSwkHQiWceZZp7ZAtJETBG1sY6NaGj2K6wqHwymVmIS2xiTqYFSorYrzI/yfmKnJt6PGqp8fHDYaatu0mo1ALITGw/jyt9y2+anvWuPyVWMfCcqzzNXxaiioKS1RP06OlkdK8D2RM962N69689iM9avlwRcWUcqWfEiihxBNR3hQCWRRQ1HeE1HeEBFFDUd4UdR3oAqC2+5a3BNiWc5b5zgfbbDWSRHX+FMRZH+e5qr0c+ixc8pDlP7n92mttEcvDJkl2obbprzcwPM7/zYfpXW3h7SrGPFnOrLUpuXUam42lkbWE6lrQCVE8ggR3RerPPEquPsM2CZ5vB5ZLimCQ0bX0kLamuqqyfzcNLAX8PG7QFzufRrQSfpVuAdFsS8lRirI7Ln2cyxHzlRV0lohefuY2Olk+mVnuUa6qujSc1vO1vD2tRRe4qWfyZ2zuk2N3bGKG7y1ueVcTKimv8AUgsiiqY9S2FkQ14IHklrj6TtCDr6IC1t5NiuQ4TkNwxPK7VPbbvap3U1ZSzDR0UjezuIIIIcORBBGoIW/hYt77e6dTbccZObYXb4mZ3ZYdIw3Rv2Vpm6k0zz/dBzMbj26tPJ2orLO+kp6tV7Hz8P4LC5tU4501tRqa6KK5amlqKOolpaqGSGaF7o5I5Glr2PadHNcDzBBBBB6ELi0KuyqzIaaq7O7dvB5Tu7Z7FlFmD6y1VnDBebWX8LK2nB6jsbKzUljuw6g8nFWnUQdFrKKmnGS2GYycXrLeb58DzrGNpWJW3N8OucdfabrCJoJW9R90xw+S9p1a5p5gghVAtPG6TvV3nd1y34Nc/hFfhd3laLtQMJc6B3ICqgb/dGj4zfltGnUNI274/kFlyqyUOR45c6e42y5QMqaSqp38Uc0Thq1zSvOXdq7aWXM9xd29dV45856CIvKyvJrVheL3fL77I+O3WShnuFW5jeJwiiYXu4R2nRp0HaVFSz2Ikbj1VAnTsVrtne89sG2pwxHENpdmkqZQNKGrmFJVgns81LwuJ9WoVzwQ9oe3m0jUEcwR61tKEoPKSyMKSltTIk6ppxdQFDUKZq1MkA0jpy9SFvEC1/pA9QeYKimoWNoPOuON49d2PjuthttayQAPbUUkcgcO4hzTqrSbRtzTd12lUkrLls4t9prZGkMuFkYKGojP3X2sBjvU9rgr2rws2zjE9neNVmXZrfaW0WmhYXzVNQ/hHg1o6ueega3Uk8gF1pzqRa1G8zSUYtfEjSjt22UVmxHavkGzKsuAr/ALETMMFWGcJnp5Y2yRPLfku4HAOA5ag6clQBOpVe7d9psu2Pa5lG0l8MkEV5rS6lhk+NFSxtbHAx3iI2N18SVQBK9TT1tRa+/nKCeWs9XcR1C5aWhqLpVwWukjL56yVlPE0fKe9wa0e8hddXh3RMAl2l7xGF2EU5lpaS4su1b3Np6U+dOvgXNY35yTlqRcnzCMXJqPE3MUbY8fx+AVz2sjttEwTO15BsUY4j+aVogzbKJ83zTIMyqXF0l8ulVcCT3SyuePoIW5zesyx+Fbue0LIYZOCdliqaaF2vSWceZZp46yBaR44xFG2IdGANHsVXhcdkpk+/e2MTkPRSqJOqh1VtlsK8gSNPUoBzfuh71sI8lZhdLU0G0HMbhQwzslmobVCZYw8eg2SWTTUf4SP6Fno7FsaedXY7a3euji+qq2vfxo1HDVzyJtKzdWCnnlmaBA9n3Y96nEjPuwt+wxbGW9Mdtg/zKL6qHFsZPXHbWfXRRfVXL3ouj5nT3e+l5Ggtp864RxAvcfktBJ9wXfoMbyS7u4bVjl2rTyGlNQTS9fwWlb6KbH7DRyiekslvhkbro+Olja4e0Bd5jGRjSNob2eiNP0LDxThHz/gysP4yNJuJ7qe8Xm8rI7FseyRrJNCJq6l+BQgHt45ywLIfZt5LbaFdpYqvannNrsFLqC+jtTTW1RHa3zjg2Nh8RxrZb168/WpgFxnidWWyOSOsbGmt+0tlsZ3cdkmwa3mm2fYvFDWzRhlTdKk+erqkdzpXcw37xvC3wVzOYUygVAlOU3rSebJcYqKyiUBvAZe3AtiOc5cX8L7bYaySE6/wzoyyP89zVowa3gY1muvCAPctsvlJMqdYt2ypskU/BLkl4ordwjq6NrjO8erSEe9anXN5q7wuGVJy4sq7+Wc1HgSqLSmhUDyVkyCZ8+SoxUTXzPs5kj/5LS0dohee+RzpZAPYyNbFNQsSfJm4sLHu7S3+SLhkyO+1dWHEfGiiDYG+zWN3vWWmo7wvNXstevIu7WOrRiTcQUCdVLqO8KOo71FJARQ1HeE1HeEBFB1UNR3hRBHXUICda+fKt5OCNnmFxyc+Kuu0zNe4MhjP50i2C68tVqV8o3lxyTeZr7SyXjhxq00VsaAeQe4Onk+mYD2Kdh0daunwIl7LKk1xMX0RF6Ip0QOmmp6BVM3ZbtOkY2SPZtlbmvAc1wslUQ4Eagj7XzBXUwXHZMxznHMRhaXOvd3o7doBz0lmaw/Q4rffDEynhZTwjhjiaGNGvQAaD9Cg3d5yZpJZ5km3tvb5tvLI0MSbMdpkfJ+zjK2+uyVX7NdS4YRmtno5LjeMNv8AQUkWnnKiqtc8MTNSAOJ72ADUkAanqt+nPvPvXl5RjFhzTHbjieU2yG42m6076WrpZhqySNw0I8D2gjmCARzCiLFXntj5kh4fwkaCFAlXh3o93a/7uW0SXHqoTVWP3IvqbDc3jlU04PON5HITR6hrx2+i4DR3KzROqt4SjOKlF7GVsouD1ZbybUK4GxDZzi21bPKPCcn2i0+Gi46RUdbU0JqIpqguAbCSHsEZdqeFzjoTo3qQregaqcHRJJtZJ5GY5J5s2rbOvJqbBcRkirMwqLxmdXGQSyulFPSE/wCJh0JHg5zllFjuNY7iNphsOK2Kgs9tpxpFSUNOyCJnqa0Aa+PVYWbim+h+6yOh2K7WbqPs5G1tPYbvUP8A/eDQPRppnH+GAHouPxwND6Q9LOfQdy83dutGerVeZeUPZuOtTRLpqpgNEUVFO4REQBYGeVayowYngWERTaGuudVdZmA9WwRCNhPzpj7lnmtU3lM8s+zu8RTY7HJxRY1YaanLQeTZZ3Pmf7eExqbh8Naunw2kW8lq0X1mJQCiBqoKYdF6MphwhbhNwPEG4luu4pI6Isnvxqb1MCNNTNKeA/xbY1p+jgmq5GUlM0umnc2KMDte48LR7yFvqwDGosMwXHcQga0MslqpbeNBy+1RNYT7wVVYpPKChxJ9hHObke+iIqQtAiIgCIiAIiIAqezPNLVhlsNbXO85PJq2npmnR8zvDuA7T2fQuHN87tmGUPnJiJ62UH4PStdoXn7p33LfH3KytssmU7WMikrKmZxZqBUVTh9qp2djGD9DR6z3ryOkGkUrOasMOWvcS2JLbq9b6+rvezfhs6Ap8r2tZQXc5Zn6cbuYhpYteXqA7upPir+4ZhNnwm2fAbazjmk0NRUuHpzOHf3Adg7F3Mbxi04rbGWuz04jjHOR55vld9049p+gdi9Q+iNSeS6aP6OLDM7u7evcS2t78s9+X3f2CXOFZ3altF+G+dxuwz/1uCWVVQw/2Q9rGn7nvPb06defaNtM+ECWwY5OREdWVFU0/H72MPd3u7ezlzVrS3ULx+mOmKq62HYfLZulJc/+K6uL59y2GcszrOZ7Vxlq7TmeC9TGMTueW3Jtut0ejRoZp3D0IWd5/oHavmtvRq3VSNGjFyk3kkg0cOJYfcsyurbdQNLYm6OqKgj0YWd57yewdvvWSeP4/bMatUNotUPm4IR283PcernHtJXHjOM2vFbXHarXFoxvpSSO+PK/tc49/wCjovWX3jRfRmngVH2lXbWktr4f4rq4vnfcaqKW0IiL1hsEREAREQBERAEREBiL5TbJ/sTu/UmORTFkmRX6lp3NB+PFC18zvZxMYtVpZos8PKoZYanL8GweOT0aC3VV1lbr8qaQRM1+bE/3rBJ5Xo8Phq2669pSXktas+o49CoKdPYppF2lT4htW2nbP6Ke24LtAv1gpKmb4RPDbq10LJJOEN4nBvU6ABVNDvQbxkI0ZtvzH23N5/SrYEaKC5unBvakbKclsTLr/wBVRvIf37sv/KLv1KYb1W8iOm27Lvygf1K0+pUQVr7Kn0V4GfaT4sux/VU7yP8Afty7+Xn9SnbvV7yI6bbct/l3/wClaXXuKmB1WfZU+ivAe0nxZdv+qw3kwOW23K/5YP1Lgm3r95Tr/wAN+Wfy3/8AStWei4J3hjS53Ro1KwqVNftXgZ9pPizbX5PHJto+cbGrnm20fMrtkFRcb5NBQvr5ePzVPCxjCGcuQMhfr6lZ3yrWUBztnmExyHUGuu8zfUGQxn6ZVlJuh4h+4bdr2f2N0fBNJZ4rhONND52p1ndr/Gaexa9vKOZcch3m660MlD4sbtFFbQAeQe5rp3+37c33KptUql45Lcs/Qsq7cLZRe95GMQ6IRqjTqFFXhU5EpC24+TtxV2ObsNjrpI+CTIK6tuzuXMtdL5th/Eib71qOfxcDuAau09EDtPYt7GxvEmYHsmw/DWs4TZ7JR0jx/hGxN4z7XaqsxSeVNR4sn2Ec5uXBFZKBGvIqKKiLYwX3990JmRUlbty2ZWn/AI3pmGbIrdTM51sTRzq42j+FaB6YHx2ji+M30tcPLsOo8F9Ay1j7+u6TFs1uU22PZ3bfN4tdKj/jahhb6FrqpHcpGAfFgkcenRjzp0c0C5w+8zyo1O70Ky8tsv6kO8wvI0RRd3KCtytCyr3Jd7qp2J32PAM7uD5MEu0/KSQk/Yeoef7M3uhcf7I0dPjjnxa4pk6BS8XDzXOrSjWg4S3HSnUlTlrRPoHgmhqYI6mmmZLDKwPjkY4Oa9pGocCORBHPVY9b/uYfuR3XspZHKWT319NZYiDoT56VvnB/Ftk9ixr3A98UWKpotg+1O7aW2oc2DGrnUP5UshOjaKVx6RuP9jcfin0OhbpU/lXMrEGM4Bg8VSOKtuNXdp4QefBBEImOI7uKd3uVHTtZUrqNOXHPwLWddTt3NGu8yNfpxtDu0ajVVZjW2DalhgjZie0fJrSyL4kdLdJmRj5nFw/QqM17lAuV+0pbynUmtxf2z79O9LZQGR7VKisaCDpX0NNP07NSwHT2quLN5TLeMt7XNuNLiN1LtNHTWx8Rbp1/scgB1WJQOqmauMrai98V4HWNaqt0mZnt8qTtq4QDgOFE9p4aoa/61Qd5UnbXpo3A8Kae/hqj/wCqsNANFKVpyOh0UbcprdIyuyDyl28fdY3xWpmKWQOPJ9LbHSvaNOgM0jh7S1Y/7Qtre0navcWXXaLmlzv08RJhFVN9qg16+biboyP5rQqORdYUadPbCKRpKrOovieZOXaqXqoKeCCeqnjpaWCSaeZ4jiijYXPkcejWtHMk9wXU0yON3f3dVs/8nBu9Vez/AAur2v5VQyU96y6FsVuglbo+ntgPEHEHmDK7R2n3LWd6ttukeT6uNfV0O0rb5a3UlHC5tRQYzMPts7hza+sHyGdCIfjH5eg9E7FGMbGxrGNDWtAAaBoAO4BU1/dxkvZU32ljaWzT9pPuMSvKZ5WLLu+0uORy8MuSX6lpy3X40UIdO/6WM961Wu6rO/yqWUGqy3BMKjk9Ggt9XdJWj7qaRsbD7on+9YHu6qZh8NSgnx2ke8lrVmuBBRHVSFy45JC1jnN5kNJA8exTGRjbx5OrFDjm7JaLk+LgkyO4Vt1JI5uYZPNRn8WIH2rJxURsQxNuDbHsKxBrOF1qsVFTyDTT7YIml/5xKrdeVrT9pUlLiy/pR1IKPUFKW9ymRcjoS6FNCpkQEAAFFEQBSu6qZQPRAa9fKoZV52vwHBY5RpFHWXidnbq4thjJ9glWAbxzWS/lB8rOSbzd8o2ScUOP0NFaWaHkHNjMr/zpj7ljQ86lens4alCK/NpQ3M9arJnGRoii5QUhnEuPjO8dt2wyw0eMYptWyG1Wm3sMdLR0s7WRQt1J0aOHvJPtXrN3ud5lv9uzKD66hp/3VaBxUpcubpU3vivA215rnZeQb3u8z/fryb+PZ9VR/qvd5kdNtmS/x8f1FZoOU3F4p7Gn0V4D2k+L8S8Z3vd5r+/Zkv8AHR/UUv8AVfbzQ/t2ZN/HM+orO6+KlJWPY0+ivAz7SfF+JeI73u8z27bMm/j2fVXetG9fvS3e50dmodtOSuqK+oipIRxxEmSR4Y0D0O9wVjS7RXl3OcVbmm8zgFokj44ae6i5zNI1HBSsdPz8OJjfetJ06cIuWqtnUbRlOTUc3t6zdFbKaahtlHQ1dXJVTQQRxSzyHV0r2tAc9x7yQSfWtGm3HMBnu2fOMvY/jjud/rZITr/BNlLI/wAxjVun2s5WzB9l+W5lK8N+w1kra4H79kLi0e12gWhindIYmumOr3DV5Pa48yfeoGFRzcpk2/l8sTs6nvUFLqU5lXBXGQW4diJy7eixDii44LI6ovM2o5DzMTgw/wAY9i3GjotbnkqcT+FZpnGcSRai3W2mtkTyOjp5DI/T5sLfetki8/iU9avlwRb2McqWfEIiKvJhb7bpsVxHb3s8r8By2ANEw89QVrGAzUFW0Hzc8fiNdCOjmlzTyK0u7U9lmYbHM3uOA5vb/g1xt7tQ9upiqYTrwTxO+VG4DUHs0IOhBC3xqw291ux2jeKwJ0dDDBTZjZY3y2Oud6Ic483Usrv7lJoOfyXaOHQg2Fjd+wlqT+V+RDu7b2q1o70aagOSiAu5erLdscu9ZYL7bqiguNvnfTVdLOzhkglYdHMcOwgrpK+zz3FPu2HLFJJBIyaGR8ckbg9j2OLXNcDqHAjmCCAQR0K2hbj2+WNq1JT7KdqFyjbmVHFw26vkIb9mYWjmHdnwhoGpHywOIcw5auhyXYt9zrrPX011tdZNSVlHMyop6iB5ZJDKwgtexw5hwIBBXC4t43ENWW87Ua0qMs0fQIixg3L9763bfbA3EMwqYKTPbTADPHyY26Qt0HwmIdOIfwjB8UnUeieWT685VpSoycJby7hONSOtEIiLmbkDz5d/JaP95nLWZzvA7QMmil85DPfaiCB2uusUBEDNPDSP6Vug2h5PFhWBZHmEzgGWS01dwJPT7VC54+kBaEnVM1W99ZUuLpqhzppSe17iXO+klW+FQ2yn3FdiEtkYhNVAnVQVyVpdHdjxA55vB4BjToPOwy3ynqahmnWGA+ffr4aRlbvhz59/NarvJi4iL3t7uOUSs1jxuxTvYdNdJqh7Ym/m+cW1JUGJzzqqPBFtYxypt8WERFXE0IiIAiKDnBoJJAA580BFUXn+0ahxGA0dJwVNzkbqyLX0Yh2Of/QOp9S6GY7SRAXWrGXCaoceB1S0cQaTy0YPlHx6d2q6OK7KzVVDb3mDXSvcfONpHnUud91Ke38H39y8biWN3N/VeHYItaf7qn7YLt53+LPmzkUvi+C33aHXnIcgqZo6KV3E+d/x5/vYx2Ds16Ds1V7bXabfZqGK3WylZT00Q0axg+k95PaSuyxrGNaxjQ1rRo1oGgA7lxV9worZSyV1fUsggiGrnvOgH6z4KywfArXAqTqN61R7ZTlvfO+xfjbMHNJJHEx0sr2sYwFznOOgAHUkqzu0LaPJdxJZbDK6Oh5tmnB0dP4DuZ+n1dehnG0SryZ7qCg46e2tPJuujpvF/h977/CjuoXz3S3TN3ilY4c8qe6UueXUuC6977N+yjxOAs0QM8Fz8IVTYZg1dlVSJCHQUEbvts5HX71uvU/oXz6zsq9/Wjb20daT3Jfm7i+Y3PLxjELplleKSgj4ImEGeocPQib3+J7h2q/2OY5bMYtrLZa4eFg9J73fHld2uce/9HYuxarTb7LQx2620zYYI+jR1J7ST2k967i+7aMaK0cBp+0n8VZ73w6o9XF735HN7QiIvWmAiIgCIiAIiIAiIgCgeiiiA1+73m6JvCbcNt9zzfFbPZZLKyjpKCgNRd2RSOjij1cSwt9HWR8nL1KyZ8nJvSf+H8d/Lsf1VtuRT4YjVpxUFlkiJKzpzk5PPaajz5OTelH/AFex4/6di+qn73JvSf8Ah7H/AMuxfqW3BFt7zrdRjkNLrNRx8nJvS/8Ah7Hvy7F9VP3uHelP/wAgx4f6dj+qtuKLHvOt1DkNLrNR/wC9wb0o/wDkOO/lyP6qh+9x70o/6vY9+XYvqrbiie8q3UY5DS6zUgPJxb0h62HHR677H9VP3uPejH/yHHT6r5H9Vbb0T3nW6hyCl1mo53k596UDljdgPqvsX6lCDyb28/V1MMFbj9ghppJWMnk+zcTiyMuAeQAOZDdeS24qKe8q3UZ5DS6zqW22U1pt1JaaNgZT0cEdNE0fJYxoa0e4Bax9t24/vRbS9sWZZ9R4rZjS3y81NVS8d8gDvg/Fwxag8wfNtZy7FtDRRqFxO3k5Q5zvVoxrLKRqOj8nPvSkeljdgb677F+pTO8nNvSdmO4/+XYv1Lbeile863BfneR+Q0us1VYP5O7eHo81x6rynHrGLNBdqOa4mO8xPd8GZM10mjQNT6IPLtW1QADkOnYooo1xczuWnPmO9KhGjnq84REUc7BdG+WO0ZLZ63H7/boK+23GB9NV0s7eKOaJ40c1w7iCu8ibgaudq/k39sVtzq4wbJrfRXnFpHiW3z1l0hp54mO5+ZkDzq4s6cfyhoeuoVJt8nXvTu64pZG+u+wf0LbkisFiVZLLYQ3Y0m89pqNd5OnemHTF7Ef9Owrid5Onep7MTsh/07Atu6LPvOtwX53mOQ0+LNQp8nRvUkEHErJof/r0CzZwXd6yPbJsYocB3w8Ooqm/42/4La75Q3JslZJTcI4X+eZza8acLg7Vr+FriCdSsoNAUA0XKpfVaiWeSa51vOkLSnDPrNf+deSpo5JHz7NNq8sDD8WlvlEJdP8ALQ8J/MKsbk/k5N5+wyP+xthseQRNPJ9tuzAXD8CYRlbc1AgFbwxGvHe8zWVlSe7YaRrzupbydgc4XHYplZDASXU1F8JboO3WIuCpOt2X7TrWwPuezbK6Rpdwh01kqmDXu5sW+XQDpyTn90feuqxSfPE5uwjzM0IswjN5OTMKyFx8LTUH/cXfptlG1OuZ5yj2ZZbM3i4eJlkqiNe74i3v8+8+8qOp7z71n3o+j5/wY5AukaOLfu4bwF2k81b9iuZyO1DfStEsY1Pi8ABXExvyfu9NkT2GbA6WyxP01kul0gj4fW1he76FuBIJ6kn2qIAC1lilR7kjZWEOds167P8AyVU5fDVbUtqTAzkZKKw0nM+Hn5v0iNZb7JN2HYnsTaybBMJpI7i0aOulZ/XNa7/Kv1LPUzhHgrqIolW7rVdknsJELenT2xRLoVDQ9ynRRzsa+N8bdU3h9te264ZjiOJ0NVZIqKkt9DJLd6eJz2RsJceBzgW6ve/kVYl/k8961x5YJbfy7S/WW3zRNB3KfDEatOKhFLJfnEiSsqc5OTb2moA+Tv3rz/1Gtf5epfrL1sP8nXvInLbI7J8QtdPZ23KlfcJBeqd5bTCVplIa06k8AdyC206DuUVl4nWayyRhWNNcSVrGsaGMADW8gB2DsUyIq8mBERAEREAREQBQI15FRRAastr25bvVbQNqGV5vDs+pHxXy8VVbFrfKQEROkPmwQX8vQDeSo4+T83rif+bqkH+m6T662+6BNB3KxWJ1YpJJfneQnY02822agf3vjeuPP/g9ofbfKT66HyfG9f8A3vqH8t0n11t+0Hcmg7k951uC/O8cgp8Wafz5PbewPTZ7Q/lyk+upf3vTexP9r6gH+nKT663BaDuTQdye863BfneOQU+LNPh8ntvZD+15RH1Xyk+uot8ntvYO67PKEeu+Un11uC0Hcmg7k951uC/O8cgp8WagB5PLeuP/AFCt35dpfrKR3k897AHlgFvPqvlJ9dbgtB3JoO5PedbgvzvHIafFmnl3k897Hs2fUP5cpPrrI3cU3Qdrmx3a5X55tTxmlt0EFmmpLe6OvhqHOnlkYHHSMnTRjXcz3rPnQdyaBaVL+rUi4NLabQs6cJKSz2Fnd7bDs8z/AHf8rwfZvZhc73fYoKJkBqY4B5l0zDK7jkIbyY13LXnqta8Xk997Nx57NaZn4V7o/wCiRbi1DQLSheVLeOrBI3q20a0taTZp+b5PTevI57PqEeu+Un10/e9t64H/AJvqH2Xyk+utwSgu/vStwX53nLkFPizHDcU2FZZsJ2UXK0Z7aoaDILteZayeOKoZMBC2NjIhxsJB5Bx08VkgiKBVqOrNzlvZKpwVOKiuYIiLQ3CIiAw/33tzOfbMyLaRsvt0H7tYTHBXUpkZCy6U40aHFziGiWMaaOJ9JgLTzDdMOx5P3etP9rinHrvVH+0W4MkdE0Cm0r+rRioLaRalnTqS1mafj5PretH9ruk/LVJ9dcL/ACf29cDy2bwH1XmkP/qLcPoO5QLV0951uC/O805DT4s1F41uQb5mJX2hyfGMKFsu1snbU0dXDfKNskUjehH2z1gg8iCQdQStoOx+9bSr5gtBU7XMQhx3KYtYK6mgqo54JXNA+3RuYSA1/XhJ1adRzGhNZcOnYogLhXupXCSmkdqVvGi/hbJkRFFO5aTeuxjOc22AZdhuzmzOul9vlLHQQ04qI4ftb5WCV3FIQ3lHxctea1nxeT+3sZOZ2Zws/CvVH/RItxB59VEBS6F5O3jqwSI9a2jWlrSbNPzfJ7b1ruuz6iHrvdJ9dRPk9t61p/5vqE+q90n11uB0HcmgXf3pW4L87zlyGnxZiduA7umd7CbDltVtKsUNtvN6rKeOBsdVHPrSxRkg8UZIGr3u5eCyyUAAOiioNWq603OW9kqnTVKKigiIuZuERUzlOeWnGmuga4VVbpygY7kzxeez1dVFvLyhYUnXuZKMVzv82vqB7d0utBZqR1dcalkMLe13UnuA6k+AVsbtlGRZ5VusuO0skdIfjAHQub91I7o0eH6Vy0GNZLn9Wy8ZJUSUtD1jbw6OLe6NvyR98eZ8Vce12i3WWkbQ2ulZBCOZA6uPeT1J9a8vON/pNsWdG2fdOa+yfn1mdx4WJ4Jbsba2qm4aq4ac5iPRjPcwdnr6+pVOokaKj8y2iW/Gmvo6Isq7j082DqyLxeR/N6+pXcpYfo5Z5vKnTj4t/Vt+Jg9zIMiteNURrblPpryjibzfIe5o/p6BWOyzMLplVX5yrf5umjJ8zTsPoM8T3u8fdovPut3uN6q311zqnzzP6lx5AdwHQDwC6Tua+PaS6W3GNt0aWcKPDnfXL03Lr3m6jlvJQp2jVI4pJXtiijdI95DWtaCS4noAB1V2MH2Xx0vm7rk0TXzcnR0h5tZ3F/efDoO1UmD4Jd45X9jbR2LfJ7l2v7b2bN5Hh4Ps2qL75u6Xhr4LfrxMZ0fP6u5vj7u9XhpaSmoqeOkpIGQwxDhZGwaNaFygADQdFFfdcC0etcBo6lFZzfzSe9+i4L6vac28wiIr4wEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBQVEbbbtc7Fsnyi8Wavloq2kt75YJ4ncL43gjQg96xT2C7Xtpd/2uY1Zr5nl3raGrqpGTU81RxMkHmXkAjt5gH2LKWYM5EUB0UVgBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBQd0UUQEimHRRRAEREAREQBERAEREAREQBEUCUBFcNXV01DTvq6yeOGGMaue92gCp7Is8tNjDqeE/DawchFGfRafvnf0DUrwKXGslzWojuOVVL6SiB4o6Zo0Ong35PrOpVBeY5GNV2lhD2tbgvlj1yluXZv5gQvGb3nJal1kwmkm9Lk+p04Xad41+IPE8/Beli2zWgtL23C8vbX12vFoRrFG7vAPxj4n3KqrZarfZ6UUdtpWQRDmQ0c3HvJ6k+tdtc7XAnVqq7xSftaq3L9kf+2P3e0Eumh1XHV1lLQ0z6usqI4IIhxPkkdo1o9a8HLs7smJQltVL5+scNY6WMjjPcXfcjxPs1Vk8kzG95bUecuVRwwNOsVNHyjj9nafE8/Uo2P6W2mCp0ofHV6K5v8AufN2b+zeCtcv2rTVofb8Yc+CA+i+rI0kePvB8keJ5+pW4dqSXOJJcdSSeZKlZyXJpqF8XxTFbvGK3t7qWb5lzLsXN9XznSOSJQNV6VksFzyGsbRWymMr/lOPJkY73HsCqLENm9yv5jrbgH0VvPMOcPTlH3oPQeJ5etXgtVnt1lpG0NrpWQQt6ho5uPeT1J9a9Jo9oXcYtlXus4Uv/dLs4LrfcmHLI8XEsCtWLsbOGipryNH1Dh8XvDB8kePUqpuFRA0UV9msrK3w+iqFtBRiuZffi+tnMIiKUAiIgCIiAIiIAiIgCIiAIiIAqfznOcb2dYzWZZlNcKaho289Ob5Xn4scbflPceQH9AJXpXq8WzH7TV3u81sVJQ0EL6ipnkOjY42jUkrWrt6243vbRljq2R0tLYaB7mWqgJ0DGdDK8dsrh17h6I6HX0ejmAVMcuMpbKcfmf2XW/Lf2+c0jx+GB2+cdtSXyr7vqXnuL3S7+1+fNIaXZzbxDxu835y4ScfBry4tG6a6aa6ctVMzftyZw1/4PrV/LpfqrEuGXTQLuxS8l9UWieC/9BeMvU+Ty0sxv/rvwj6GVX9XXkvbs+tf8ul+quaHfjyOU88Btg/zyQ/7qxVEiuDsT2a3Hatm1Nj1KZIaKIfCLhUtHKCnB5n8Jx9Fo7zr0BXK40awG1pSr1qKUYrNvOXqb0NJcfuqsaFGs3KTySyjv8DMfYptjzTazUzVVRhNJbrLTAtkrhUvdxy6co2NI9I9p58h4q8K82wWG04xZ6SwWKijpKGijEUMTByA7z3knmSeZJJXennhpoX1FRK2OKJpe97joGtHUkr43iNe3uLiU7WnqQ5ltfe829r8D7Thtvc21tGF3U9pU53klt4LJLYjkReRYbpLfonXeNro6GQltI1w0dKwH+ynuBPQd3PtXrqE1kTwiIsAIiIAiIgCIiAIiIAiIgCIiAJ2gd5RQ05g+IQGNN7338csd9uVjm2f3aR9trJqN0jauEB5jeWFwB7Dpqr17L9o9l2q4dSZfZGPhjnc+KamkcDJTStOjo36cteh8Q4Fa3dobC3aBlOo6Xuu/wBu9V7u27bJdkmZ/BLtK847enshuDD/ANHeDoyoA7266O7269oC3cVkYzNiGqhxKSKWKeNk0EjZI5Gh7HsOrXNI1BB7QQkj2xMdJI5rWsBLnOOgAHUk9y0MlN7SdoNm2ZYhWZbeQZGU+jIadjg19TM46Njbr2nmfAAnsViaffhs9TXU1C3Z9XtdUzxwNPw9hALnBup9HxVnt4na3U7WM0+BWR8stitUjqa2xMBPwh5Oj5+EdS48m/egd5VpLS8jIbWD1Fwpgdf8a1dFFZbTBtaB1CioN7fWormZKF2xbU6PZBiTMsrbPPco31kVH5mGVsbtXhx4tXDTQcKsj/V54+Ouzm6fy+L6qqrfXGux2D/zql/myLGjdt2Z4vtS2hT41lsVVJRMtk1U0U9QYXeca+MA8Q7NHHl6lukss2YL2f1e2Nj+11df5dF9VQ/q+Ma157Ort/LYv1KsHblOw8/9Fvn5Uf8AqUW7lWwwdbfez67rIsbDJJss3t7BtSzahwmiw25UE9c2VzZ5qmN7GiOMvOoHPmGq/eoVqMF3ZNlOznJqXLsZoLlHcqISNifNcJJGgPaWu1aeR5Eq6qw8uYEeLwVgdpO91ZdnGcXTCKrCbjXS2t8bHVEdVGxj+ONr9QCNR8bT2K/p6LXNvSv02+ZZ/jqb/wDGiWYrNmGX6G/ZjxGp2dXUf59F+pRG/fig187s/vLe7hqoSuLY3uw7Kc42Y47ld9o7o6vuVGJpzFcHsaXcRGoaOnRVdU7luxOoidGynvsLndJGXNxLfUHAj3hZ+EHHjW+jshvc7aa7tu1ie4gB9XTCSL2uiLiPaFe2y32y5JbYrxj91pbjQzjWOoppRIx3hqO3w6rEPaTuPXG1UE912aZDNdTC0v8AsZXta2d4HZHK3RrndwcBr3qymyba5luxfKhcLeZzS+d81dLVKS1s7QdHNLT8WRvPR3UEaHlqE1U9xk2bIvOx6/WzKLFQZHZpxNQ3KnZUwP72OGo17j2Ed4XorQFO7QsoteFYVeMqvVvfXUNspjPPTsa1zpWggaAO9Ht7VZDZ5vPbL81zqzYxZ9mU9DX3Ko8zT1boKUeZdwOdxat9IcgRyVxd5M/+wrNP/LHfz2rBzdpdrt3wwf8A1B3+xkWySaBsuHRRUB0CitQW42zbabdsbo7XWXCx1VyF0mlha2CVrODgaCSeL1rr7GNulu2yy3WO349V2z7FNhc8zzMfx+c4tNOHppwlWp3638FlxDxrKv8A2bF0dxWQPqMxHaI6H9Mq2y2ZgyzXRvd7tGN2qpvl+uMFBb6OMyT1E7w1kbR3n6AOpPILy86z7F9nOPzZJldxbS0sXJjR6Us8mnKONnVzj3dnU6AErAbbJtqzLbZfIqV0U1NamThtts1OS/V5OjXP0/ssp10HLQa6NHUnCWYzMhqrfjwuOqmiosMvNRTskc2OYyxRmRgPJ3CebdRz0PMdqvjgGWV+a45BkVbi9fYW1R4oKetc0yvi05SEN+KD2A89OasLu+bqkOPilzTadSRz3QFs1JaXaPjpT1D5ux8g6hvxW9up6ZOjxWZZcxhEURFqZCs7tj3lca2Q3+lxupstVdq2am+EzNppmMEDSdGB3F2uAJ07vWrjZtllswbFLplt3fpS2umfO4a6F7gPRYPFziGjxK1sukyja7tDDpCam95NcAOZPC1z3aAeDGN9zWrKQM5djW8fje2K81lgorNV2qspacVTGVMrH+eZxcLuHh7W6tJ8CrurWHiOQX7ZTtBpb3DE+K4WGufHUQO1bxhriyWI+Dm8Q9oK2WWC+W7JbJQ5BaJxNRXCnZUQPB6scNRr4joR3go0D0ERFgDuWNGQb72MWC9XOyy4Ldpn2yrmpXPZVRAPMby0kA9h0WS/aPWFqp2knhzzKh3Xiu/2z1tFJ7wbSbLcmXqzUF4jidE2upYqlrHHUtD2BwBPhqu6vEwb/wCCsf8A/KqT/YtXtrUBERAEREAREQBERAEREAREQBERAEREAREQBF1LldbdZ6Y1lzrIqaEfKedNfADqT4BW/rdo96ySrdacFtkjz0dUvaNQO/n6LB4nn4KJdXtK1Xx7W9yW1vsQK2vuS2fHYPPXOrDHEasibzkf6m/0nkqMF7y/PHOhstObfbSeF0xOmo8Xdvqb713rFs0gE/2Uyurdc6x54iwuJjB8Seb/ANHgq2YxkbGxRMaxjBo1rRoAPAdiqqlpe4rsuJOlT6MX8T/7pc3YjB4GP4VaLCWzlnwqrHPz8rfin71vQfpVQjmdU05Kkcs2lWHFw+mjkbXV45fB4ncmH793yfV18FMlLD8Bts3lTprz+7fizLZVdVVU1FTvqqyojghjGr5JHBrWjxJVpc22xyS8duxBxjbza+te30j/AItp6fhH2DtVEZPmV9yqfzlzqvtLTrHTx+jGz1DtPidSvC01Xy/SDTuveJ0MOzhDpfufZ0V59aME0ss1RK+oqJXyyyHie97i5zj3knquWLkAuFrVW2H7NbzknBV1LXUNAefnpG+lIPvG9vrPL1rw9jY3WJVlRtouUn+Zt8y62ZR4Ntt9bdaplFbqWSonkPosjGp9Z7h4nkru4hswobTwV9983V1g0c2LrFEf94/QqosGNWfG6T4LaaQRhwHnJDzkkPe53b6ui9TRfYNH9CLfDsq97lOpw/avV9b2dXOZzJVM1RRe8MBERAEREAREQBERAEREAREQBERAFA8goq2G8XtZj2P7MbhkNPIz7LVf9YWmN3PWpeDo/TtDGhzz+Dp2rvbW9S7rRoUlnKTyRxubinaUZV6ryjFZsxs3z9ucl+vEmyTG6v8A4stcrXXeWN3/ACmqbzEOo6tjOmve/wDBWLPXouN1TLUyyVNRM+WWVznySPOrnuJ1Lie0kkknxUwevveF2FLCrWNtS3Le+L533/wfA8Uvq2KXUrqrve5cFzLu/k5o3aHxXZjk0XSDlyMeVYqRWygepTiSeRkMLHSSSODGMaNXOcToAB2knktj+75skg2T4HT0VVAz7OXINqrpKOZEhHowg/csB08TxHtWJe5zs4jzfac3ILjB5y24vG2ucCPRfUk6QNPqIc/5gWwTVfNdPMXblHDaT2LbLt5l9/DgfSdAsHUYyxKqtvyx+7793c+JKrR5flT88zWl2Z2KcmhZNrc54z8cM5vaD9y3TTxcfBVVtYzE4diNRU00nDX1mtLSd7XEc3/NGp9eiondvxxsVFc8qnaXS1MnwSJ7uvC3Rzz7SR7l87gtVObPpReiGGKnhZTwMDIomhjGjo1oGgHuU6IuRkIiIAiIgCgSewKKIAiIgCIiAIiIAiIgCdo9YRB1HrCA1dbSWA55len/AHxXf7Z6vDvS7D3Y+yg2rY/TuNvu8cIu8bRyp6tzG6SjubIevc/8LlaTaM3izzKvG8Vw/wBe9bKJbJa8gxQY/eqKOroK2hZT1EEg1a9hYAR4eB6g6FbyeWRhGOm6Btrdc6KPZTk1VrV0kRdZ5nnnLC3m6An7pg5t+91HyV2N7fbf9gaKXZZjVVpcK+EOu08budPTuHKEHse8cz3MP3wVh9qWzzIdg20OFtvq52RRTCvslxA5vY12oB7ONh0a4dvI9HLsbH9mN82+bRamvv8AU1EtAJzX3ytJ0c8udr5tp7HPIIGnxWgkdAmS3mS5W6vsWNVbptrmSUxEUEUpskLm/He1pBqT4AghniCewLF2zO1yG1k9tfTH/WtW0+qoqO1Y1PbrfTR09LSUL4YYYxo2NjYyGtA7AAFqssbtchtI7TcKX/atWYvMxkbZQooi5mSwe+r/AMzsX/nVL/NkWKuxLaszY9mMuVusTrt52hkovMNqBDpxuY7i4uF3Tg6adqyp31f+Z6H/AM6pf5six33WMCxPaJtGq7JmVoZcqGK1TVDYXyPYBIJIwHasIPRx963ju2mC6Z38oz02Yu9t2H7JQG/pC06P2YSaeF2H7JXe/qXNgw6bPab+V1H11Id1rYIeuz2n/ldR9dYziCo9kW0iPavg1LmkVodbW1U00Qp3TCUt828t14gB1016Ksl4uH4ZjWBWOPG8TtgoLdFJJKyASOeGueeJ3NxJ5nxXtLUyD0Wt7epk4dv+Wjunpv8A8aJbITyBWtjepdx7wGXkdlRTj/8ArRLaO8wzN3dpOuwjC3d9tH89yuarZbs402DYUD/3Y3+e5XMJ0WHvMkD3LXpvfY/Q2HbfcpKGNkbbtSU1ykY0aASvDmvPrJj4vW4rYWT3LXJvRZRR5htpvddbZWy0tAIrZFI06h/mW6PIPaOMv9yzHeDKXcwvc912LxUU5J+xNyqaRhJ+QeGQD2ecKvsSrJbn+OzWHYnb6ipgMUl4q6i4aHqWOIYw+1rAfar2LD3gtrvJ/wDMTmf/AJa7+e1YPbs7f/bxhv8A9+//AGMizi3khrsKzMf/AE1389qwk3Zmf+3bDv8A76Q/6iRbLcDZMOg9SioDoPUorQGK+/dzs+HAf9srD/q2K0+wDbLadjFoy+5VNJJX3O4x0kVuoxq1sj2mUuc9/wAljeIa9p10A7rtb9Q/4pw//wC7rP5kasPse2K5FtkvE1HaaymoaChLDXVcx4jE12unBGOb3HQ6DkO8rdbtpgp3Pdo2XbTL2+/Zbc31U3NsELfRhpmH5ETOjR49T2krLXdP2VbN6HHKfaDbLpFkF9nbwSzvj4RbZNBxQsjPNr+fN55uHxdGnn0dqW5/jhwWnbs1p5I75Z4nOPnpOJ10HVweegk+5I0HyemhGNmyzatlGxfLjdKCOR0Jf8HulsmJYJ2NOha4H4sjTrwu6g6g8iQW9bBkbKworwsJzXHtoWNUmVYxWipoatvLXk+J4+NG9vyXtPIj+ghe6tDIUDyCiqU2o57Q7NcHueW1nC59LHw0sJP9mqHco2e13M+AJQGNG+ZtRdc7nBsutFRrTW9zaq6Fp+PUEaxxHwa08RHe4dy9Lcv2UNiZVbVbvBq5/HRWoOHQdJZR6/iD5yxiuFwrb1cqq73SofU1lbO+oqJSfSe97iXH3lZC2DfOp8QslBjdo2WQx0NugbTwsF0Ooa0dT9r5k9Se0krdrmBLvlbL2WW/0e0i10/DS3p3wavDRyZVtbq15/DYD7WeKqnct2kGrtlfsxuUw87Ql1fbS53N0Lj9tjH4LiHDwee5URtA3uKHaTh9yw+8bMmxw18WjJm3TV0ErTxRyNHmuZa4A6ajUajtVlMGzK44Fl9qy22H7fbahspZroJGdHsPg5pI9qc2QNoaLz8fvluyax0GQ2mYS0dxp2VMDx2tcNQD4jofEL0FoB2j1haqdpXPO8qcP+967/bPW1btHrC1VbRG65tlH/m1cf8AXPW0QbOsIGmF2Ad1rpP9i1e2vHw0aYhYm91spR/qmr2FqAiIgCIiAIiIAiIgCIiAIiIAiIgCLqXO7W2zUrq2610NLA3q+V2gPgO8+AVs73trfWVX2Jwe0yVlRIeFkskZcSe9sY5n1nT1LDeQLm3K6W6z0rq261sNLA3q+R2mvgO8+AVu7ltdqLrVfYjBLPNWVL+TZpGa+0M7vFxAXSt+y3J8rqmXfaDeZmA8xTMeHSAd2o9Fg8ACrlWTHrLjlL8DstvipY/lFo1c897nHmT61ykpz2ReS8wUPbdmd0vdQ2657dpaiU8/gscmoHgXDkB4NHtVfUFuoLVTNorbRxU0DOjI26D1nvPiV211LndbbZ6R1ddK6Glp2dZJXaD1DvPgFzhRo2qdR7OLf3bB2QdF5WQZRZMXpfhV4rmQ6j0Ih6Ukn4Lep/QrX5dtykfx0OHwebb0NbOz0j4sYenrd7la6rrq25VL6y4VUtRPIdXSSPLnH2leJxrTy2tM6WHr2kul+1fd+S6zRz4FfZZtdvV9D6Ozh1sonagljvt0g8XfJ9Q96oPXnqTqTzUjQdOi5YoZJ5WQwRPkkeeFrGNLnOPcAOq+WX2IXeK1va3U3KX06kty7guJFuhXpWaxXS/VYorRRSVEp68I9Fo73HoB61XOI7G6+r4K3KXmjgOjhSsOsrh98ejPpPqV27XaLbZqRtFaqOKmhb8mNump7yepPiV6vBdBbnEMqt5nThw/c+7m7/A2KNw/ZParLwVt64K+tGjg0j7TGfAfKPieXgq+4QiivrGHYXaYVS9jaQUV5vrb3syERFYAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgIE6DVa7N+LaU7LtrIw+iqeO3YlD8GLWn0TWSAPmd6wPNs8OFy2CZBd6fHrFcb/V/wBgtlJNWS/gRsLz9DVpwuV7rMhu1dkNxkc+qutVLWzOdzJfK8vP0uXuNCLNVLmd1L9iyXa/4z8TxWmt24W0LWP73m+xfz9Dnjk00XO1+vMFecyTRc7JV9RjI+YSp5Hea5cjHeK6bZPFTSS8EbnA9Gk/QusXmRpx2Gxrcxw6PG9jNLenxBtVklTJcJHEc/NA+biHq4Wk/OKvwQFTWzK1Cx7OcXs7Q0fA7PRwnhGg1ELdT71U2mug8V8AxW5d5e1a7/dJ+GezyPvuE2qs7GlQS3RXjlt8zGTeByZ9zzY2VkmtPaImxADp514Dnn182j2K9uye3MtuzyyRMABmp/hDvF0hLv6QsU87r312bX6rd1kuNRy9TyB+hZdbPnxSYJj74HBzDbafQjv4Br9Oq4VVlBInoqBERRzIREQBEUBr2oCKIiAIiIAiIgCIiAIiIAg6j1hEQGsDaO4DP8q/85rv9u9bNLU7itlGe+niP5gVo7vukbHb3dK2719Fd3VNwqJKmYtuT2gve4udoB0GpKvFTU8dLTxUsWvBCxsbdTqdAABqfYtpPMFK7Ttl2M7WMfZj+StnYyGdtRBUU5a2aF45HhLgRoQSCNP0BTbM9meObKsaGM44JnxOmfUTVFQWmWaR3a4gAcgAAAOQCq1FqDpXv/3NX/8A2s38wrVLjQ85k9mH3Vxpf9s1bY6iCOqp5aaUEsmY6N2h0OhGh/SrJUW5tsTt9dTXCmoLwJaWZk8etyeQHMcHDUac+YC2i0t4L49/rREWoMft9t/m9j1OT23umH5kn6li1sD2xWrY3mVXk91s9Zco57dJRMipXsa4OdJG7iJeQNNGH3rPnaXsyxjaxj0eM5Y2rNFHVMqx8GnMT/OMDgOYB5aOPJWsduQbEHHXgyD8qH6q3TWWTMFOR7+uHSf9QL4P85g/WuT+rtw7/wABXv8AlMH61UDdyTYoz4rb/wDlI/VXM3cs2LD+Dv35SP1U+EydXB98PFc4y604fSYbeKWe7VLaaOaWaEsYSCdToddOXYsgFZ7FN1DZRhuS27K7My8iutc4qKfztfxs4wCObeHmOavGBoNFq8uYEh6Fa2952Pj2/Zif/wCXD/8AjxLZOQCrQZhusbKs5yi45ffobs64XSRss5irixmoY1o0aBy5NCReQLMbLN77Edn2zuw4ZWYleqqotNIKeSaKSEMe7iJ1bq7XTn2qppN/HDeBxiwK+Ofp6IdUQNBPiQTp7lU7tynYm7pDfR6rk76qg3cp2JtOphvx59Dcz9VZ+EFjtom+PneZW6ez45bafGaSdpZLLDMZqpzT1AkIaGa97Rr4hUzsP2BZFtcvEFZV0lRR4zFIHVlwc0tErQeccJPx3HpqOTddT2A5g41uzbEsXmbU0eDUtXM0gtfcJH1WhHc2Qlv0K5sMMVPEyCCJkcUbQ1jGNDWtA6AAcgEzS3GDgt1vorTQU1rttOynpKOFkEETB6LI2gBrR6gAuwptAocPitTJbbePIGw3Mde22uH57VhPuyaO274gP/5kp/1Ei2E5jiVpznGbhiV888aC5xeZn8zJwP4dQeTuzmArcYVurbLMCyi35dYRePh9tkdJB5+u42alpadW8PPk4rZPJAvAOgUURagxa36v/dOH6/8Aa6z/AGbF0txUfbMxOnRtEPplV+9p2x/ENrcFvpstFdwWySSSD4LUeaOrwAdeR15NC4tmGxjDNkn2QOJCvH2T835/4VU+d+Jrw6chp8YrbPZkYK8WNe8/u3ty+Kp2iYNRAXyFhkuFDG3/AJewD47B/dgOz5YHfprkoiwnkZNb+xPbTfdjOQGrpxJVWiqcG3K3F2gkaOXG3X4sjew9vQ8umwjEstsGcY/SZPjNwZWW+tZxRyN5EHtY4dWuB5EHoVbPMt1DZLmuRVuT19Pc6Oqr3iSdlDVCKJ0mnN/BwnQu6nvPPtVQbLdiGM7IJav9yd6vr6SuGs1FV1TZYPODpIG8I4XactQeY69AstpguIsHN7jat+63OP3E2yoLrXjL3RS8J9GatI0kPiGD0B48azgmjdLDJE2V8Re0tD2acTCRpqNeWo6qwp3K9kskkk9VcsmqZpXOkkkkuDeJ73HVzieDqSSUjkt5hlG7qmw/HchxKtzTO8dpblFc5fM22Grj4mtijJD5QPvn6gHuZ4q8s+7lsPndxSbNbR81r2/ocq9s1ot+P2iisdppm09FQQMpqeJvRrGAAD3Bd1YbzMls2btuw1o5bN7WPbJ9ZY272WxOzYBW2rKcNs8dBZq5nwOogh1LIalupa7mTpxt19rD3rN5U/neEWLaJi9ZiWRRSOoqzgLnRENkjc1wc1zCQdCCPpKJ5Ax13LdqImpavZZd6r7ZBx1tq4j1jPOWIeo+mB3F3csqlZDGt0nZ3iN/oMlsV8ySCut07aiF/wALj01HVpHBzaRqCO4lXv8AUjA7R6wtV+0JodnWTtHbdq0f6562oKxN23Ntkt6utZeKuryAT11RJUy8Fa0N43uLnaDg5DUpF5Ap2yb6eze22egtjscyN7qSlhgLmxQ6OLGBpI+2d4Xot329mZ+NjuRt/wAlD+0XZbuUbHmdKvIv5ePqqb+ot2Q9PhWRfy9v1Fn4QdR++7svYCf3P5KdBrygh/aLIGkqWVlJBWRtc1k8bZWh3UBwBAPvViDuVbHz1q8jP+ft+or8UlNHR0sNJEXFkEbYmlx1OjQANfcsPLmByoiLACIiAIiIAiIgCKl8q2k4fh7XNu92Yalo5UsH2yY/NHT26K19VtnznNqt1q2f2B9O13LzjW+emA7y4+hH7dfWs5AvJfsmsWM03wq+XOGlbpq1rjq9/wCC0cyrWXnbjdrxU/YjArDLJNJ6LJZWeckPi2Mch63FRsmw26XapF2z+/SyzPPE+CGQve7wdKenqaParp2LGrFjNN8EsdsgpGH4xY30n+LnHm72lYBbC0bJcoyadt22iXyZrnc/g7Hh8uncXfFZ6mgq5lhxewYxT/B7HbIaUEem9o1kf+E48z716y4KutpKCnfV11VFTwRjV8krw1rR4krEmorNg5ge9cFdcKG2Ur6241cNNBGNXSSvDWj2lWry/b7aaDjo8SpxcZxqPhMoLYGn70dX/QPFWbv+VZBlVV8Lvt0mqnA6sYTpGz8Fg5BeLxfTaysM6dr/AFZ9Xyrv5+7PtRylVS2IvLlm3m30wfSYjT/C5RqDVTtLYm+LW9Xe3QetWfveR3rI6o1l6uU1XJ8njd6LPBrRyaPUF5bO5ThuvVfL8Vx6+xmWdzP4eitkV3c/a82c9Zy3nIwkrsxkdSdAvbxPAMly54dbaEspddHVU3oRD1H5XqGqvZiOyXHMaMdVVMFyrm8/OzN9Bh+8Z0HrOpUjCNFr/GGpU46tPpPd3c77tnWdIxbLZ4hsuv8AkzWVc8Zt9C7n56Zp4nj7xnU+s6BXkxnCMexOMG2UfFUEaPqZfSld7fkjwC99RX1jBtFrDBkpxWvU6T39y3L69Z0SSJANVMBooovSmQiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgLS7198kx/d5zethe5kk1u+BMLeus72xfoeVqpYdAADyWzPfmlki3bsi4DoH1VvY7xBqo1rFZKDovp2heULGb53J/RHzfTBOd7BcIr6s7zXkLkbJoum2RcjXr2cZHjpwO82XkEml+0vPcw/oXWa/kpi7iaW69Rou8ZZEadPNG5DEZBNitlmaQRJbqZwI6c4m9F6w6j1q3e7zkMeU7EsLu7H8TjaIKeU6/wkLfNPHvYVcRfn+7pujXnTe9NrwZ96tKirW8Ki3NJ+KMHs5ppKDNr9SStc10VyqOTuuhkJH0ELJzYDeG3bZlbotRx26SWjf813E381wVmN4/GXWTPTeY4yKe9wtnB7BKwBjx9DT7V6W7TmUdpyCqxWtm4YLuGvp9TyFQwdPnN1HraFtNa9NNHdbzJpERRTIREQBERAS+kDppqO/tRrw/XTUaHTQjQqZQQEUREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBFDUDqVDib3oCZFIZAOxSmU9gCA5VAkDqVxayO6aqIjd2nRATGVg8VIZzroGqcRM156leBk2fYdh0Zdfb3TU8mmogaeOZ3qY3Upk2D3WmZ3RunrChPNFSQOqqyqjhhjGr3vcGtaPEnkFY++7x1wuM/wBjMBxuSaaT0WS1LTI934MTP6T7F58Wyva5tImZW57fX0NM48QinPE5o+9gZo1vtOqzq5bwVnl+8NhOPcdPaDJe6pvL+tzwwNPjIeX4oKoiLItt21pulmpX2u1yHTih1p4dPGV3pv8Am+5XMxPYlgeKllR9jfsnWM5/Ca7SQg/es+I33a+Kr0ANAa0AADQAdAmaW4FocX3drHRObWZbcZLrUE8ToYiY4NfE/Gf7x6ldO3Wy3WelbQ2qgp6OnZybHDGGN9wXcXj5HlmOYpS/C8hu9PRs01a17tXv/BYPSd7AudWrCjFzqSSS53sRhtLaz1gdOq61yutts9I6uutfBSU7Oskzw1v09VYnLt5Wol46TCrWIW9BWVg4nHxbGOQ+cT6laS75JfcjqjWXy61NbKejpX6hv4I6NHgAF4zE9NrS1zhaL2kuO6Pq+5ZdZHncxWyO0vzl+8Ra6MPpMOozXTcx8KqGlkLfFrfjO9ugVmchzDJcsqPP367z1Wh1ZGTwxs/BYOQ/SvCZzXK0L5zimO32LP8A5ifw9FbI+HP35nB1JT3nKwlc8YXqYxh2R5ZOIbFapqhoOjpdOGJnreeQ/Sr1YjsGs1s4KvKaj7JVA5/B49WwNPj2v+geC0wzR6/xeX9CGUek9i8efuzOkIOW4tBjeIZDlc/mbHbJZ2g6PmPoxM/CeeXs6+CvTh+xCyWfgrcjkbdKsaHzWmlOw+rq/wBvLwVx6akpqOBlLR08cEMY0ZHG0Na0eAC5ei+mYPoVY4dlUuP6k+v5V2L1z7iRGmokGRsiY2KNjWMYNGtaNAB3AKZEXskstiOgREWQEREAREQBERAEREAREQBERAEREAREQBERAEREAREQFkd9K1uum7VmQYTxUcNPW6Aa6iKojcfo1WqmObU6ardPnWMQZthV+w+qIEV7ttTb3OI14fOxuYD7CQfYtKNTSVlor6i03CJ0VVRTPpp2OGhbIxxa4H2gr32h9wvY1KPB5+K/g8TpVbOVWFXisvB/yejHJ2rnY76V50Muq7bH8l7unLM8RVp5Hda5cjea6rXLmY/TkpKZGcTPDyfO0OOtxq+bMq2oHwi2T/ZShY483U8ugkA8GyAH/KLLxaidkm0m6bKc+tGcWvieaCbSogB0+EUzvRliPraTp3ODT2LbJjeRWfLbDb8mx+sZV265U7KmmmYdQ5jhqPUR0I6gghfKtL8Ndrecpivgqbf93P47/E+maKYgri05NJ/FD6c3hu8Cl9s2BHPcOmpqKIOudATVUXe5wHpR6/fN5evhWIFJLVUFWyeF8kFRTSBzT8V8b2nl6iCPoWfKsFt62Rg+fzzGqUknWS500bffO0fzh87vXmaNTL4WeqLj7KtotJtBx9s0sjGXWjAZXQDl6XZI0fcu09h1CrZYO4tk94xG8098sdT5qogPQ82SMPVjh2tPaPURzAKy32fbRLLtAtYqqFwgrYWj4VRudq+I94+6aex3v0K1qU9V5rcCq0RFyAREQBERAEREBBRREAREQBERAEREAUOiioEaoBxKKgBoooAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiKGunVARUNR3qHU6qGh7kBNqFAuTQpw6oCUvKhxHvU4YAohoHYgOPQlRDHKfkF1LneLTZac1d4udLQwjmZKiVsY+koDs+bHaVENaOgVq8k3kMAs4fFaHVN6nb/ANnbwRa/4x+n0Aq3lRtq2ubQJ3UGFWV1Kx/LShgM0jR99K8cLfXoFsoNgyMut6tFipTWXq50tDAP4SolawezXr7FabLt6HCLJ5yDH6WpvU7dRxtHmYAfw3cz7Gqk7fu553ldS25Z7lHwZzubmukNXUerUnhb7yrn4rsG2bYq5lQyyi51bOfwi4nzxB7wz4jfYFnKKBaODNtvG18FmO0U1vt0h0L6QfB4gPGd3pO+afYqnxfdihEgrs3yGSqlceJ9PRktBP30rvSd7APWr7MYyNjY42hrWjRrWjQAeAUeixrcAeTj+KY5ilMKXHrNTUTNNCY2em78J59J3tK9YLzb7klhxmjNwyG80dupm/wlRKGA+A15k+AVnsp3rMSoeOnxC21F4mGoE8wMEA8RqON3uHrVdeYnaWCzuKiXVz+G85VK0KXzMvoqHzDbJgeGccFddm1daz/olHpLID3OIPC32lYw5Ttp2gZlxxV97fS0j9R8EovtMencSPSd7SVRnj3814nEdOHthYw75fZL7vuIc77PZBF5Ms3k8vvfHTY7TxWSmdqA9p87UEfhkaN9g9qtfWXGuuVS6suFZNVTyHV8s0he53rJ5roRgrnYB2rwt7iN3iM9e5m5fRdi3IiupKbzkzlaSueN3f2KscP2NZ1l/BPT2w0FE/n8KrQY2kd7W/Gd7Bp4q+GH7AMMx3zdVd2uvda3Q8VQ3SBp8IxyPziVYYboziGJ5ShDVhxlsXdzvuWXWSKdGc9pYzENn+V5k8Gy2qR0GujqqX0IG/OPX1DUq92I7AMetHBV5LObtUjn5oAsp2n1dX+3l4K6UcUcMbYoo2sjYOFrGgBrR3ADop19BwvQ6wsMp1v6k+vd3R9cyZChGO/acVPTU9JAylpII4IYxoyONoa1o8AOS5NFFF61JRWSO4REWQEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAWrXft2XSbPduVXkNHSmO05mw3Wnc1voipGjalnr4+F/qlC2lKy+9psT/4bdklbabZTMfkVncbnZXHkXzMaeODXulZqzu4uAnorfBL5WN3GUn8L2Pv5+5lZi9o7y2cYr4ltRqdgdy9a7sR1XRiikjeYpY3xvYS1zXjRzXDkQR2EHkQu9FyA5L63Rew+X11tOduq5WuK4h2adqnHNTYkCR2YzrospNzjeKbs7uo2dZlXBmNXWbipKiR3o2+qceZJ7InnTi7Gu9LoXLFmPqF24SuF9YUcRt5W9ZbH5Pma7DrZ3tXD66r0XtXmuDN0AIcA5pBB5gjtQgEEEAg8jqsKN1Des+xbKXZntQuelEA2G03ad39g7GwTOPyOga8/F6HloRmu1zXAOaQQRqCDyIXxrFcKr4TXdGstnM+Zr83rmPrmGYnRxSiqtJ7edc6f5ufOWH2rbA+N02R4HTekdZKi2M7e90P1Pxe5Wasl2u+N3OO5Wqqmoq2lcRxDk4Hta4Hs7CD7Vm8qDz/ZBjucB9fGBb7sRyqomaiQ9nnG/K9fXx7FDhVy2SLDI8/Zztrs+ViK1X4xW27EBrdTpDUH7wn4rj9yfYSrmEaLDzLcCyTCar4Pe6AticdI6mP0oZfU7v8AA6HwVX4HtqyHGmxW+8cV1tzdGgSP+3RN+9eeo8HewhJUk9sDJkoi8LGc1xzLYBLZbiySQDV8D/RlZ62nn7RqF7q4NZbwEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEXDVVdLQwmoramGnib1fLIGNHtPJUJf9u2zPH+Nj8gbXzN/gqBhm5/hD0fpWUm9wLgosdr/vXyAGPGsUY0nk2Wvn1J+Yz6ypl983jNqOjbey6wUcvLSljFDBp4vOjiPnFbaj5wZLX7McWxeMy5Bf6GgA58M0wDz6m/GPsCtRlW9Zhlp44cctlbeZR0kcPg8OvrcOIj5qpSxbqeS3CUVeXZTTUpfzeynDqiU+t7tBr71c3G93TZdj7mTT2Z94qG8/OXGTzrdfCMaM+grOUFv2mCzjtuO2naNK6iw+2yQMedOG1Upkc0ffTP109foru2zdx2l5ZUtuOa32KhLzq51TO6sqPcDwj8ZZO0tHSUFO2koKSGmgYNGxQxhjAPADkuXUhY18tyMlscV3edneNhktZRzXqqboTLXu4ma+EbdG+/VXIpaWlooG01FTQ08LeTY4mBjR7ByXI97ImOlke1jGjVznHQAeJVusu3gtlOHccVXk8NfVM5fBrcPhD9e4kei32kKPXuaVBa1aSS62c6lWFJZzeRcgHvUss0METp55WRxsGrnvcGtaO8k8gsS8u3ysgreOmwnG6a2xnk2prnefl07wwaMB9ZcrP5FtDzfNZC/KMnr69pOvmny8MTfVG3Ro9y85d6VWlDZRTm/Bee3yK+ritKGyms/JfncZk5fvE7McTD4Yrx9mKtuo8xbgJRr4yahg95PgrHZjvWZ3e+OmxikpbDTu5CRv2+oI/CcOFvsb7VZBvTkpwCV5K+0lv7rNRlqLhHZ57/oV9TEK1XnyXUdy63a75BWuuN9utXcap3WWplMjvZr0HgFLB6PRcTANNSqpxHZ9mWaTNjxrHqurYToZ+Hghb65HaNHvJXnfZ1bmeUU5Sfa2znDOTyW88mJy9Ggo6q41DKOhpZqmokOjIomF73HwABJV+MO3UWsMdVnN/wCPoTR2/kPU6Vw1/FA9avfjOGYth9N8Fxqx0tC0jRz42ayP/CefSd7SvRWOht5dZSuH7OPi/D1fcWVKynLbLYY54fu4ZlfPN1WQPjsdI7Qlsg85UEeDAdG/OPsV8cO2PYLhgZPQ2ptXWs/6ZWaSyA97Rpws9gCrUDRRXt8O0bw/DcpQhrS4y2vu5l3In07anT2pbSB59VFEV8dwiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAwE35d2huPV9TtuwigIttdLxZBSxN5U1Q46fCmgdGPOgf3PPF0cdMPmBbta6ho7pQ1FtuNJDVUlXE6CeCZgfHLG4aOa5p5EEEggrWjvV7rtZsTu5yrFYZqnCrjNwxO5vfbJXHlBIepYejHnr8V3paF30HRjG1USsrh/EvlfHq7eHE8NpFhDpt3dBfC/mXDr7OPAx+aNNFysauNnPRdiMcl72DPETORjF2Ihz1XHG1czB+ldokaew7cLtFkpu9b2t82cmDFc6NTd8Z9GOGUHjqbcOnoa/wBkjH3B5j5J+SsaYl2oz3Lhe4fb4jRdG4jnF+K60+Zm1piFfD6qrW8smvPqfFG3nG8msGX2enyDGbtTXK31TeKKeB/E0+B7QR2g6Edq9Naqdm21nOtlN1F1w29PpuNwNRSyDjpqoDskjPI/hDRw7CFnDsd3tcD2kthtOROjxq/P0b5ipl/raod/gpToNSfku0Pdr1Xy7GNE7vDs6tD+pT4reu1fdd+R9MwfSu1xHKlXepU69z7H9n5l76yjpLjTSUdfSxVEEo0fFKwOa4eIKtLl+79b6svrsOqxRSn0jSTkuhPg13Vvt1HqV3wQRqDyPNRXlYycdx6sxJumPZThlYw3W31VvlY77XO0ngJ72SN5fTqq0xjbbk9sLILy1l1pxyJkPBMB4PHX2g+tX+qKenq4X01VBHNDINHxyNDmuHiDyKoK/bE8RunFNbGyWqc8/tB4otfFh6ewhdPaRlskgezju0jE8jaxlPcm01Q7+Aqftb9e4E8newqqP6VYC77G8utJMlHHFc4R207tH6eLHc/dquC0ZLl+LSfBG1dXTcHI09Q0lo+a7p7Fh00/lYMhkVs7TtdlIay8Wpru+Sndp+af1qrbdnOM3INEdyZC93yJhwH3nl9K0cWge+ilZIyVofE9r2noWnUKZagIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiKSaaGnYZKiVkTB1c9waPeUBOipS8bVdnNh4hc8ytjHt6sjmEr/wAVmpVD3jej2fUPEy00dzujx0LIhCw+151+hZUWwXjTwWMl03rMnrXGDHcXt9M53JnnpH1En4reEarx5L5vMZ47SiZfooJeQFPTtoYgPwiGnT2rbUfODKquuVutcRnudwpqSIcy+eVsbR7XEKgcg3hNlGPcTJMmbXyt/g7fE6cn5w9H6VZqg3Ytpd/kFVk99oqRzjq51RUPq5fo5fnKtrLuj4ZTcL8hyC6XNw5lkRbTRn3au+lZygt7MbTxr/vf07WuZjGHvd9zNcakMH4jNf5ypUbW94TPz5vG6OrZE86f8VW7haP8q/XT18QWROO7IdmmLaOs+HW5krf4aaPz8nr4pNT7lV7WtY0MY0Na0aBoGgHsTWityBivQbvu2DL5G1eY3iKk4jqTcKx1VKPUxpIB+cFXti3WMSoi2S/3243Nw5lkQbTxn3au+lXsUFhzbMlN2DZzg2L8LrHi1BTyN6TGISS/ju1d9KqPUqm8p2lYDhUTpMqy+120t/g5ahvnT6mDVx9yszlm+5s1tIfFi1pul/mGoDywUsH4z9XH8VRK13QofqSSIta9t7f9SaX18DIvULhra6ittO6ruNZBSwMGrpZpAxjR4kkBYJ5Vvm7Wr/xw2Jtsx2B3IGlh89MB/jJdRr6mhWiv+WZTl1R8KyjI7ldpCddaupdIB6mk6D2AKmr6RUYbKUXLyXqVVbH6MdlKLfkvUz3y3eg2PYqHxx5GLzUt1HmLWzz3Pxk5MH4ysllu+rlddxwYZjNDaozybUVjjUy+vhGjAfxljRGdNAFyjmqC6x68rbIvVXV67yqrYzc1tiequr1KsynahtAzd7jlOW3GujcdfMGXghHqjbo36FT0ZGnLouBo1XNGNCB2uOgHeV5+rKVSWtNtvrIqqSm9aTzZ2GErtQu00Vb4VsF2pZv5ua24xPR0cmh+F3AfB4tO8cXpO+a0q/GG7nOO0Bjqs3yKpuko0LqWjHweDXuLzq9w9XCpVtgt5e7acMlxexfnYWNCzr1tsY7OsxmttFV3SpZRW+knqqiQ6NigjL3u9TQCVd3EN2HaLkXm6i7xQWCldoS6rPFNp4RN56/hELK/GcMxTDaT4Fi9gorbFpo4wRAPf+E74zj6yvZ0XpLTQ+jH4rqbk+C2Lx3/AELajhUY7arz7C1uGbuOzjExHPWW918rWaEzV+jmB33sQ9Ee3U+KuhFDFBE2CCNkcbBo1jGhrWjuAHIKdF6m2s7ezjqUIKK6vzaWkKUKSygsiCiiKSbhERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAF0r1ZbTkVqq7HfbdT19vronQVNNURh8csbhza5p6hd1FlNxeaMNJrJmuneS3MrzsyNVm2zeOou2KNJlnpOclVa29uvbLCPu/jNHxtQC5Y1RAEDhOoI1BW6vr1WLG33cmx7MfhWV7Ko6WyX15dLNbT9roqx3Ulug+0SHvHoE9QNS5e/wPSxLK3xB9kv/ALevjxPDY1ow9texXbH09PDgYCMbouxGzULu5JjN/wANvdRjmU2artdypTpLTVMZa4dxHY5p7HAkHsK6sRHIBfRKcozipReaZ8+q60W4yWTRyMYQu1EzlquNg15rsRhd4oiTZM1h5LsxN05LiaNdCuxGO4LqkRpMuzsz3j9qGzURUdBePspao9B9jriTLG1vdG7Xjj9h08Flls13sdm+bsipL3OcaujtGmGtfrTvd95MBw/jcJWv2MLtxPLei89iejFhijcpR1Zv90dj71uf16y8w3SjEcLyjCWtBftltXc968cuo2wwzw1ELJ6eWOWKQcTHscHNcO8EciplrKw7antAwKQPxPKq6gZrqYA/zkD/AMKJ+rD7tVkJgm+zUAR0e0PFhJyAdXWt2h9ZhedPxXexeExDQi/tc5WzVSPVsfg/s2e8w7TvD7rKN0nTl17Y+K2+KXaZYrrV1ut9zj8zcaKCpZ3SsDtPVr0VI4jtp2Y5sGMsWXURqH9KWpd8Hn17uB+hPs1VbajTXsK8jXt61rPUrRcXwayPYULmjdQ16E1JcU0/oUjX7LsYqiXUjZ6Jx/uT+Jvudr+lU5X7KLtDq623CnqWjo1+sbv6QrpIuak0dyzP2GzLHn8Yo66AD5cBLm/mr0qDP8ipSGVEjJwOomZofeNCrqdFwVFtt9aP67oYJtfu4wT71nWz3oFI0m0iN2grLa4eMT9foK9amzbH6jQOqXwnukjI+kaqaowfG5tSKJ0JPbFIR9HReXPs4oydaS5zR+EjA4fRosfCwVPT3S3VY1pq6CTwDxqu0OY1HMeCoQ4FdIDrDV08vr1aVOyy5JRf2OOTl/c5df6UyXEFcIqMNwyilOjxU8vuo+IfoXLFlV0jOk8UbvwmFpWMgVcip2LKnuGr6RvscuwzJoD8emkHqIKZA9pF5Tckt5GrhI0+LVyfugtPbVaetpWAeii89t+tDv8Ap8Q56cyQuUXa2HpcKb+MCA7aLpfZeg0cfhdPo3/DNUYrtbpY2yGtp28Q10MzdR9KA7iLq/ZO2/8AeFL/ABzf1qH2WtY63OkH+XZ+tAdtF0zebODobvRD/OGfrXVly3FoSWy5JbGFvIg1TOX0pkD1kVNTbSsAgDjJl9sHAdCBOCdfYujUbYtm1PpxZVTP1/ubHv8A0BZ1WCs0VvKjbzs4gBLLlVTaHT7XSPOvv0Xj1m8vgtNr5m3XabnoPtTGA+9yzqy4Au2isXVb1NnY3SkxSdzuzz1Wxo+gFeRPvP5LUv4bViFEdfigvllP5oCz7OQMi1DULGobaNud3c5toxUt/wARZ5X8PtcSEFRvSX1oLY7rTMf/AIOnptPfoQmpxYMltD3FdWsutstzS+4XKlpmjqZp2s/SVjodkO3u9hv2Xyd8YPUT3iR2nsZqF2aXdXvVURJes0pQ8/G81TPlP4z3D9Czqx52C71x2s7NrUdKzNrUHD5Mc4lPuZqqWum8zsut5c2nrLhXuHT4PRuAPtfwry6DdVwyIA3LILxVntEZjhafc0n6VUVv3d9k1AQ5+NvrHDtqqqWT6NQPoT4EChLrvdWuMFtnw6okPyXVdWyMe5oP6V4T943a3kB81jOH0o4j6Jp6Oaqd7+n0LIG1bPsGsgAtWI2imI+U2kYXfjEEr3o2MiaGRNDGjkGtGgHsCa0VuQMYQN6vLOrLpQxv7zDRNA+hynj3ctquQO89k2WUcZd8bz9VNVP93T6Vk5omuie0a3AsHa90uys4XXvMK6o+6ZSU7IR73cRVZ2bd32U2jRzsffcHj5VdUPl/N1DfoVydR0C4KyvobdEZ7hWQUsQ6vmkbG33uIWrnJ72YbS2s61qxzH7EwR2Wx0FC0cv63p2R/SBqu+SSe9W5yTeM2J4rxsum0S1SSs6w0bzVSa92kQKtPk2/rs7t4czFsUvd5kHIPn4KSI+0lzvzVwnXpw+ZkKtidpQ+eovr9DJ8KPXpzWBeQ7921K5h8WP2Gw2VhPovMb6qUD1vIbr81WuyTb7tjy3jZetot5dFJ8aGnm+DRkd3DEGj3qLPEaUflTZV1tJbWH6acvL+fI2UZJneFYfCZ8qyy02poGv9d1bI3H1NJ1PsCtHlG+jsYsQeyz1dxyCZvQUNKWRk/wCMl4Rp4gFa+ZZZKiYzzyOkkdzc95LnH1k81Fqg1MUm/kWRU19J7ieylFR836eRlLlO/dmdcHw4hh9rtTDybNWSOqpR48I4Gg+9Weynb7tizLjZes/uggf1gpHili9XDEG6+3VUAE0VVXu61X5pMqquJXVf9So35LwRyOkfLIZZHue9x1c5x1cT4k8ypge1SAaKdjC57Y2gue46NaBqSfAdqrZI5RZyscuZjlX2G7vO2DNiyS04VW01NJzFVcB8Fi079X6OPsaVfLDtxV2sdRnub69C6ltMP0edk/oYulLDbm5fwQeXF7Czt8PubjbCDy69hizGQdDqOarzDdjG0zOXMdj2IVz6d/8A0qdnmIAO/jfoD7NVnHhewnZXgTWPsOIUjqpmn9d1g+Ez694c/Xh9mir7QaAdg6DuVpR0az2159y9X6F1Q0f560u5ev8ABizhO5QxojqtoGVEnkXUdrboPUZXj9DR61fXENj+zbBeCTHMSoYahg5VUrPPT69/nH6kezRVkivbbC7S0204LPi9r8y5oWFvbfJHbx3sgRr1KhwlTIp5MIAaKKIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiICj9pWyTAdrVn+w+cWCGtDAfg9S30KmlJ+VFKPSb6uh7QVhRtZ3Is/wAI89d8CmfldoZq7zMcYbcIW+MY5S6d7OZ+5WwdFc4Xj15hLyoyzj0XtX8dxT4ngVniqzqxyl0lv/nvNOxglppn01RDJFNE4skjkaWvY4dQ5p5g+BXOxvbotoO0vYPsw2rxuflWORC4cPCy50mkFWzu+2AemPB4cPBYp7R9yPPMa87X4FXxZNQN1cKdwEFa0d3CTwSetpBP3K+kYXpfYXuUKz9nLr3dz9cj5viuiV/ZZzor2kOrf4emZje0HkuzG3lquW52m52K4SWm92yrt9bCdJKaqhdFK31tcAVLGOgXr4tSSktx46ecXqy2NHKxunMrsMbqVxNbqdF2Ixy10WyOMmcjWarnY3RSsC5WLKRwkznjceWvPRVti21zaPh5YLBl9xhiZ0p5JTNDp3cD9QPZoqIaAuZhWlW3pXEdStFSXBpP6madzVt5a9GTi+KbT8jI/Gt83JqMMhyvFaG5N6GajlNPJ6+EhzT9Cunj29fsnvQay4VNxs0pA1FZSlzNfw4+Ie/RYQ6a6LljBHavOXehmE3W2MHB/wCL+zzXkeks9OMZtNkpqa/yWfmsn5mySxZriOTRtlx/JrZXhw1AgqWOd7W66j3L3NdOq1jxPcxwkadHtOocOo9qq+xbVdomOsEdnzO6wMb0jNQ6Rn4r9R9C83c/6ey321fukvus/oemtf8AUpbrqh3xf2fqbBydUWFtt3qNrNAW/Cq223BreoqKIAn2xlqq2175lzjIbfMFpZR2uo6xzD7ntP6VSV9CcWpfJGMuyS++Rf2+n2DVtk5Sh2xf/wAczKVFYe274Gz+pAFzsN8onHqWsjmaPc4H6FVFs3lNj1xbq/KTRO+5q6WWM+8Aj6VUVcAxSh89CXcs/pmXNHSPCa/yXEe95fXIugpXRxv+PG13rGqpWg2sbM7k0Oo88sb+LoHVrGH3OIKqCkvForxrQ3SjqQRqPNVDH8vYVXVLatR/Ug12pos6V3b1/wBKal2NM5TRUbutLF+IFxG020660cfPu5Ltg6gEcwe5R9hXEkHnmw2s66055/fFcL8YtTxpwyt8RIvV1CahMweFNh1sl00mqWaddHA6+8LrTYFb5Pi19Q35rSqm1Cis5sFEVeyy31LXAXaoY53b5ppXlS7ELfKP/iGqB/xDCrmIsqTQLUSbALZJ1yWrH+QYuL+p3tBPpZPXeyCMK7iLPtJcQWkZu6Y9r9uyK5PHhHGP6Cp4t2/DmuJlvF3kGuoHHG3Qd3JiuwoajvT2kuILYDd2wDjDnzXd4HUGrAB9zV24NgWzSF4e611cv3slbIR9BCuJxBOvQH3LGtLiCioNjGzOnboMWhk566yyyPP0uXdg2XbO6d/HHhlpJ001dTh36dVVBcG/GOnr5LoVeQWG3/8AL73b6b/HVUbP0lFrS3Gspxhtk8jrU+G4lRjSlxe0xc+L0aOPr7l6cNLTU/OCmhj/AAIw39AVLXDa/sstYLq7aLjsWh00+yMTj7gSqcr953YVbg4ybRKGYt+TTRSzE+rhaV0VvWlui/BkSpiVlS+etFdsl6l0tT3lFYa6b6exSgjLqWpvVe8dGwW8t19ry0Kkrrv9YZAXC0YDe6vT4pnqIYAfcXELdWdd/tIU9IsLp76y7s39MzKZFhPdN/7K5OIWbZ3aafU8nVVbLMQPU1rf0qkbnvu7bq7UUc1htwPTzFu4yPbI5yckqLeQqml2Gw+Vyl2L1yNg3XopZZI4GGSaRsbRzLnkAD2laxr1vI7cr6HNrNpl4iY482UjmUw/1bWn6VQt2yXJL48y3vIrrcHO6mqrZZtfxnFY5PlvZAq6aUV+lSb7Wl9MzaZe9qWzXG2F99z6wUWnyZbhEHfig6q3l/3xdgtj1bFlVRdnj5NuoZJQfU5wa36VriDWtOrWgeoaKV3Nc5RUSvq6Y3c/0oRj4v0M3L75QDE4Q5uNYBdqx3yX1tTFTt9ZDOMq3l838dqFfxMsmO2C1NPRzmSVLx7XOA+hYzIolSbW4gVNIMRrb6mXYkv5Lr33ed245AHsq9oVwp439WUTWUwA7gY2g/SreXa/3q+ymovV3rrhIerquofMfziV5mqjqFBqSb3kGpc1a22rNvtbZNry0HIKVOqi0KJPaIsAFR10OgXbt1suF3qG0dot9VXVDzo2KmhdK8n1NBKuhiu6ltyy3gkiwyS1QP0+33aVtMAO/gOsn5q4qlKb+FZkyjQrXGylFvsRaiPmudg05nosuMP3Ant4Js62gg9C6mtNLp7POy/UV6MW3Vdh+K8EkeGxXWdmh89dZXVJJ7+B3oD2NXWOG1p79hb0NHbyrtmlFdb9MzXtYMayHKakUeNWK4Xadx04KKnfMfbwgge1XixLc42x5JwS3Sgosep3cy64Tgyaf4uPiPvIWfVvttvtVM2itdBT0dOwaNip4mxsaPBrQAuwpMMHprbUbfkXVvozRhtrTcuzZ6mNuH7jmz61NjnzC+3K+zt0LooiKSAnu0bq8j5wV6sV2W7OsIDTiuGWm3Pb0mjp2umPrkdq4+9VSisKVpQo/JFIu6FhbW36UEvr4kCNeZTRRRSCWEREAREQBERAERQI1QEUUAooAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIDwctwPDc8ovsfmOM2+7QgaN+Ewhz2fgP+Mw+IIVgs03HMQr/ADlVgeRVlmmOpbS1g+E0+vcHcpGj1lyybRWVji99hr/5ao0uG9eD2FZfYPY4kv8AmaSk+O5+K2muvM92na/hHHNVYtJdaRmv9dWkmpbp3loHnG+1qtx5t0UhgljdHIw6OY5pa5p7iDzC2t+Kp/J9n2D5nGY8qxS2XIu5ecnp2mQep40cPYV7Kx0+qQyjeUs+uLy8n6o8Vf8A+n1OecrKrl1SWa8V6M1jggFc0Y16BZm5XuXbO7s58+L3i6WGV3MRlwqoB81+j/z1au/7nG060avsddab5GD6LY5TTykfgyej+cvW2mluE3eS9pqvhLZ57vM8de6H4xaZv2WuuMXn5b/Isc1vvXK1nJVJftmmf4o4jIcNu9Gxp0866lc6P2Pbq36V4DdNeHtHZ2heho1qVeOtSkpLqeZ5evRq28tStFxfBrL6hrVyNCgOfRcjRouxHciLRouVilDfBcjRotWgnmND3qRzVy6EqVw7Vg2ayOMdygSe9RKlKw0Y3nHJz66H1rg86+F3FE4sPew6H6FzP6rgeNSsGMkd6nynJqUAUmSXaAM0LRHXStAPgA5enT7VNpdHr8Gz/IGcWmv/ABhIdfeVTBHNS6KHVt6M/mgn3I707mvT+SbXY2ivYNve2Ola1sW0S7EN6cbmP/nNOq7sW81tup28Dc3kk8ZKSBx/mK2hC4nDRV1TDbKXzUYf+K9CZHF8Qpr4a81/vl6l2Id67bbCRxZLSygdkluhOvuAXcG99tnaOdws7vXbW/WVlXdVITyUKphFg/7Mf/FHaOPYrHdcz/8AJ+pe3+rE2zNJ/rqyn120fWUjt8XbOf8ApVkHqtv/APkrJOUh5KHLCLBf2Y+COq0hxb/1M/8AyZet++FtrPS42dvqtrfrLrS73u3B45X22s/Btkf9Oqs0Vxnu1UeWGWS3Uo+CMrH8Ve+4n/5P1LwSb223R3TKqZn4Ntg+qvLqt57bpVSGR20CrjOuukVPAwe4MVsHKQ8lx5DaxeynHwRmWM4jNZSuJ/8AlL1K+qNvu2eqLjLtKvo4jqeCo4B+aBovKqtqu0ytJNVtCyOTiOp1uUwH0OVKFQWjoUo/LFLuRyd9cz+epJ9rfqevVZXklZr8MyK6T8R1PnKyR2p7+ZXkVErp3cUry897jqfpUripT2LlJZbjXWc9snmBo3oNPUoF3ih6lSEqJM3SJXuK4H9Vyu6LhdyKg1UdovIkPqUpKmIUjjpqeeigVESIyZEHkolSRuEjxHGeN5PJreZ9w5qqbHsv2lZMWiwYBkFcHdHxW+Tg/GcA36VBqZIlUoTqvKCb7Clj0UqvhY9zbbzeyx9RjlHaI3/Kr6+NpHzWcbvoVysd8n1dpC1+W7SKWEfKittC6Q+oPkIH5qhTaZb0MDxCv8tJ9+z65GIqg5zW/GcG+s6LYTj249sTtHA+7R3q+SN5n4XXGNh+bCG/pKubjuxTZJiha+wbOrBSyN6SmiZJIPnvBd9KjSp6xdW+iV3LbVko+f54msbH8GzXLHtjxfELzdi46A0lFJI38YDhHtKutjG5nt0yLgkrbHRWKF3y7lWNDgPwI+N3v0WxaOJkTBFExrGNGga0aAD1BTAAdFpyaL3lzQ0Tt4bas2+zZ6mI2LeT9tcYZLmu0KqqHdXwWulbE31eck4ifxQrt4zum7CMY4Xswtl0mbofO3Sd9ST80ng/NV30W8aFOO5FzQwextvkprv2/U6NqsVksMApbHZ6G3QtGgjpadkTQPU0Bd3QdVFF13FikorJBERDIREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBERAEREAREQBQIKiiAhpy07FT192d4Lkwd9n8QtFc53y5aRnH+MAD9KqJF0p1alGWtTk0+p5HOrRp146tWKkuDWf1LOXrdS2SXUufRUVxtLzz/AKzrHFo+bJxBUXdNzCk9J1izuZp+Sysomu/OY4foWS6K6oaT4tbbIV2+3KX1zKG50Twa62zt4p9Wcfo0Yb3fdL2nW9pdb6iz3Md0NSY3H2SNA+lUhc9h+1mzamrwO6SNHyqZjZx/qyVnuoaDuVzQ08xGnsqxjLuafk8vIorj/TrDKm2lOce9Neaz8zXDcMfyC0ki6Y/c6Mj/ALRRSx/S5oXlOmj14S9uvdrzWzJ442lr/SaeoPMFeRccQxO8AtumMWmsB6+eoo3/AKWq1o/6hR3VqHhL7NfcqK/+mkv7Nz4x+6f2NcLn9OR9yhxBZ/Vuw7ZFX6mo2eWUE9TFT+aP5hC8Ot3YdjNXzjxial/+3r52/QXFWFPT/DpfPTmvB/crKn+nOKR+SpB98l/8TBl5B6Lhcs0qvdD2VTg+Yqr9TE9C2ta/T2OYV5NTuY4RJ/ybLb7F+G2B/wDuhSo6bYTPfKS7Y+mZCnoFjUd0YvskvvkYfO5KQnmssKjcltD/APk+0GtZz/hLex3L2OHNdB+5FNxuDNozOD5JdbDr7fti6f8AFuDy/u/+2XoRpaE47H+zn/uj6mLq43dCsl5tyTIQ4/B8/trh9/QyNP0OK4v6iTKj1zq0fySX9a0ekuEvdWXhL0OT0RxxbOTvxj6mM0nVcRKyWl3IMxcTwZ1ZdOzWmmUo3HMwPxs7svspZlwlpFhb/vLwfoP+Esb/APTvxj6mNJ6cwpCsoKbcayN0mlXtBtjGadY6GRx17ORcF2WbilYf7JtKgH4Nrd+0UWekOGJ/q+T9DeOh+OSWat34x9TFM81I5vPVZc0+4lS8H9d7SpuPi5eatg009smuq7kO4rjTXA1W0G6vbpzEdFEw6+skqHPSHDs9lTyfoSYaF4299HL/AHR9TDZ3LqpDos1otxfZ+AfhOZZDIdeXA2Bmg/EK9Sk3JtkNOWmor8iqtPjB9Yxod+KwEKJPSGx5m33EuGg+MS3xiv8AcvtmYJOKlB8FsHpN0DYZTaGXHa6qIdr9uuUx9nIjkvdoN2vYXbiTDs2tUhOn9n45v57iodTSK1/bGT8PUm0tAMSfzzgu9v7Gtl0jB8Z7R6zokYfUO4YGOlJ6CNpefo1W0i37KdmNp4TbtnuOQFnxXNtsPEPaW6r36S1Wu3jSgtlJTD/AwMZ+gBQ6mkEH8sH4ljS/0+rf3K6XZFv7o1a2zZ3tBvYDrPgeQ1rT0dDbJ3D38Oiq617s23W6gGLZzcYAe2qfFB9D3g/Qtk+p6an3qAaD2BQp41Ul8sUizpaBWsf1asn2JL1MCrRuQ7YLi1r7hVWK1h3Vs1W6Rw9kbSPpVZ2nyf8AO8Ndf9pkbD8plFbSfc57/wChZiAaKKhzxGvPny7izo6HYVS+aLl2t/bIx2su4xsdt4Y661uQXV7fjedrGwsd7I2g/Sq0tW61sDtJDodnFvqXD5VY+SoP57iPoV1UUaVepLfItqODYfQ/Tox8M/qeHZcHwzHGMjx/ErPbQz4vwWhijI9oGq9sg6aanTu1UUXNtveWMIRprKCyRKG+CmRFg2CIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgIaApoERARREQBERAEREAREQBQREA0CgRoiICCiAiICOg7k0HciICKIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiA//9k=" />
								  <br />
								</div>
								</td>
							</tr>
							<tr style="height:118px; " valign="top">
								<td width="40%" align="right" valign="bottom">
									<table id="customerPartyTable" align="left" border="0" height="50%">
										<tbody>
											<tr style="height:71px; ">
												<td>
												<hr />
												<table align="center" border="0">
												<tbody>
												<tr>
												<xsl:for-each select="n1:Invoice/cac:AccountingCustomerParty/cac:Party">
													<td style="width:469px; " align="left">
														<span style="font-weight:bold; ">
															<xsl:text>SAYIN</xsl:text>
														</span>
													</td>
												</xsl:for-each>													
												</tr>
												<tr>
													<xsl:choose>
														<xsl:when test="n1:Invoice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and text()='TAXFREE']">
															<xsl:for-each select="n1:Invoice/cac:BuyerCustomerParty/cac:Party">
																<xsl:call-template name="Party_Title">
																	<xsl:with-param name="PartyType">TAXFREE</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="n1:Invoice/cac:AccountingCustomerParty/cac:Party">
																<xsl:call-template name="Party_Title">
																	<xsl:with-param name="PartyType">OTHER</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:otherwise>
													</xsl:choose>													
												</tr>
													<xsl:choose>
														<xsl:when test="n1:Invoice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and text()='TAXFREE']">
																<xsl:for-each select="n1:Invoice/cac:BuyerCustomerParty/cac:Party">
																	<tr>
																		<xsl:call-template name="Party_Adress">
																			<xsl:with-param name="PartyType">TAXFREE</xsl:with-param>
																		</xsl:call-template>
																	</tr>
																	<xsl:call-template name="Party_Other">
																		<xsl:with-param name="PartyType">TAXFREE</xsl:with-param>
																	</xsl:call-template>
																</xsl:for-each>															
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="n1:Invoice/cac:AccountingCustomerParty/cac:Party">
																<tr>
																	<xsl:call-template name="Party_Adress">
																		<xsl:with-param name="PartyType">OTHER</xsl:with-param>																	
																	</xsl:call-template>
																</tr>
																<xsl:call-template name="Party_Other">
																	<xsl:with-param name="PartyType">OTHER</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>
														</xsl:otherwise>
													</xsl:choose>																										
												</tbody>
												</table>
												<hr />
												</td>
											</tr>
										</tbody>
									</table>
									<br/>
								</td>									
								<td width="25%" align="center" valign="middle">
									<br />									
                                    <div class="imgBox" valign="middle">
                                   	<br />
									<img style="width:180px;height:150px;" align="middle" alt="Imza Logo" src="data:image/jpeg;base64,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v1Kr8z/Apuf2h/8Ag4Y8XXVzPE1n8LNGhtrBk53ItvG7J/38vZfyrrwmkpT7J/5fqB+k2haPD4d0Sz0+2DC3sYEt4gxyQiKFGT9AKtUUVyAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAEGq6lFo2mXN5O22C1iaaRvRVBJP5CvzL/wCCEkVj8Xf2lv2g/iarvdtquuynTrps/vLWa6uCvX/Yih+mK/RT41366X8HfFVwxAWLSboknt+6avjz/g30+Dr/AA1/YbGpXNittceIdUlnhm73FsiRqv4CQTD866qUuWjPzshn3VRRRXKIKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAPG/+ChXiafwf+xP8S9RtjtuINDmEf1bC/1rU/Yp8D2/w6/ZL+Huk2yhYotDt58Ds0y+c3/j0hrk/wDgpjqVva/sgeIrK5+5rckGmgf3jLIBj9K9j+HPh9fCXw90HSkzs0zTre0XPpHEqf0q7+7YZs0UUVAgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA8k/bI+ErfGr4daNog3eW3iCxuJCOyxuWNetgYGB0FIyB8ZAODkZHQ0tO4BRRRSAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/2Q==" /><br />
									</div>
								</td>								
								<td width="60%" align="center" valign="bottom" colspan="2">
									<table border="1" height="13" id="despatchTable">
										<tbody>
											<tr>
												<td style="width:105px;" align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Özelleştirme No:</xsl:text>
												</span>
												</td>
												<td style="width:110px;" align="left">
													<xsl:for-each select="n1:Invoice/cbc:CustomizationID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Senaryo:</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:Invoice/cbc:ProfileID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Fatura Tipi:</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:Invoice/cbc:InvoiceTypeCode">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Fatura No:</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:Invoice/cbc:ID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Fatura Tarihi:</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:Invoice/cbc:IssueDate">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>&#160;
													<xsl:for-each select="n1:Invoice/cbc:IssueTime">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>	
												</td>
											</tr>
											<xsl:for-each select="n1:Invoice/cac:DespatchDocumentReference">
												<tr style="height:13px; ">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>İrs.No/Prov.No:</xsl:text>
														</span>
														<xsl:text>&#160;</xsl:text>
													</td>
													<td align="left">
														<xsl:value-of select="cbc:ID"/>
													</td>
												</tr>
												<tr style="height:13px; ">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>İrs. Tarihi/Prov. Tarihi:</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="cbc:IssueDate">
															<xsl:apply-templates select="."/>
													</xsl:for-each>&#160;
													<xsl:for-each select="cbc:IssueTime">
														<xsl:apply-templates select="."/>
													</xsl:for-each>	
													</td>
													
												</tr>
											</xsl:for-each>
											<!--xsl:if test="//n1:Invoice/cac:OrderReference">
												<tr style="height:13px">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Sipariş No:</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="n1:Invoice/cac:OrderReference">
															<xsl:for-each select="cbc:ID">
																<xsl:apply-templates />
															</xsl:for-each>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:if>									
											
											<xsl:if	test="//n1:Invoice/cac:OrderReference/cbc:IssueDate">
												<tr style="height:13px">
													<td align="left">
														<span style="font-weight:bold; ">
														<xsl:text>Sipariş Tarihi:</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="n1:Invoice/cac:OrderReference/cbc:IssueDate">
															<xsl:apply-templates select="."/>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:if>-->
												<!--$SIPARISNUMARALARI$
												$SIPARISTARIHI$-->									
											<xsl:for-each select="n1:Invoice/cac:TaxRepresentativeParty/cac:PartyIdentification/cbc:ID[@schemeID='ARACIKURUMVKN']"> 
												<tr>
													<td style="width:105px;" align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Aracı Kurum VKN:</xsl:text>
														</span>
													</td>
													<td style="width:110px;" align="left">
														<xsl:value-of select="."></xsl:value-of>
													</td>
												</tr>
												<tr>
													<td style="width:105px;" align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Aracı Kurum Unvan:</xsl:text>
														</span>
													</td>
													<td style="width:110px;" align="left">
														<xsl:value-of select="../../cac:PartyName/cbc:Name"></xsl:value-of>
													</td>
												</tr>
											</xsl:for-each>					                        
										</tbody>
									</table>
								</td>
							</tr>
							<tr align="left">
								<table id="ettnTable">
									<tr style="height:13px;">
										<td align="left" valign="top">
											<span style="font-weight:bold; ">
												<xsl:text>ETTN:</xsl:text>
											</span>
										</td>
										<td align="left" width="240px">
											<xsl:for-each select="n1:Invoice/cbc:UUID">
												<xsl:apply-templates></xsl:apply-templates>
											</xsl:for-each>
										</td>
									</tr>
								</table>
							</tr>
						</tbody>
					</table>
					<div id="lineTableAligner">
						<span>
							<xsl:text>&#160;</xsl:text>
						</span>
					</div>
					<table border="1" id="lineTable" width="800">
						<tbody>
							<tr id="lineTableTr">
									<td id="lineTableTd" style="width:2%">
										<span style="font-weight:bold; " align="center">
											<xsl:text>Sıra No</xsl:text>
										</span>
									</td>
									<td id="lineTableTd" style="width:10%">
										<span style="font-weight:bold; " align="center">
											<xsl:text>Referans Numarası</xsl:text>
										</span>
									</td>		
									<td id="lineTableTd" style="width:26%" align="center">
										<span style="font-weight:bold; ">
											<xsl:text>Malzeme/Hizmet Açıklaması</xsl:text>
										</span>
									</td>									
									<td id="lineTableTd" style="width:15%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>UBB - SUT KODU</xsl:text>
										</span>
									</td>
									 <td id="lineTableTd" style="width:18%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>LOT Bilgisi</xsl:text>
										</span>
									</td>									
									<td id="lineTableTd" style="width:7%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Miktar</xsl:text>
										</span>
									</td>
									<td id="lineTableTd" style="width:8%" align="center">
										<span style="font-weight:bold; ">
											<xsl:text>Birim Fiyat</xsl:text>
										</span>
									</td>
								<!-- <td id="lineTableTd" style="width:7%" align="center">
									<span style="font-weight:bold; ">
										<xsl:text>İskonto Oranı</xsl:text>
									</span>
								</td> -->
								<!-- <td id="lineTableTd" style="width:9%" align="center">
									<span style="font-weight:bold; ">
										<xsl:text>İskonto Tutarı</xsl:text>
									</span>
								</td> -->
								<td id="lineTableTd" style="width:5%" align="center">
									<span style="font-weight:bold; ">
										<xsl:text>KDV Oranı</xsl:text>
									</span>
								</td>
								<td id="lineTableTd" style="width:8%" align="center">
									<span style="font-weight:bold; ">
										<xsl:text>KDV Tutarı</xsl:text>
									</span>
								</td>
								<!-- <td id="lineTableTd" style="width:10%; " align="center">
									<span style="font-weight:bold; ">
										<xsl:text>Diğer Vergiler</xsl:text>
									</span>
								</td> -->
								<td id="lineTableTd" style="width:20%" align="center">
									<span style="font-weight:bold; ">
										<xsl:text>Malzeme / Hizmet Tutarı</xsl:text>
									</span>
								</td>
							</tr>
							<xsl:if test="count(//n1:Invoice/cac:InvoiceLine) &gt;= 11">
								<xsl:for-each select="//n1:Invoice/cac:InvoiceLine">
									<xsl:apply-templates select="."></xsl:apply-templates>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="count(//n1:Invoice/cac:InvoiceLine) &lt; 11">
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[1]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[1]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[2]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[2]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[3]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[3]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[4]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[4]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[5]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[5]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[6]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[6]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[7]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[7]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[8]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[8]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[9]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[9]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:Invoice/cac:InvoiceLine[10]">
										<xsl:apply-templates select="//n1:Invoice/cac:InvoiceLine[10]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:Invoice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</tbody>
					</table>
				</xsl:for-each>
				<table id="budgetContainerTable" width="800px">
					<tr id="budgetContainerTr" align="right">
						<td id="budgetContainerDummyTd"></td>
						<td id="lineTableBudgetTd" align="right" width="200px">
							<span style="font-weight:bold; ">
								<xsl:text>Mal Hizmet Toplam Tutarı</xsl:text>
							</span>
						</td>
						<td id="lineTableBudgetTd" style="width:81px; " align="right">
							<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount">
								<xsl:call-template name="Curr_Type"></xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
					<xsl:for-each select="n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
						<xsl:if test="cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode = '4171'">
							<tr id="budgetContainerTr" align="right">
								<td id="budgetContainerDummyTd"></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>Teslim Bedeli</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:81px; " align="right">
									<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount">
										<xsl:call-template name="Curr_Type"></xsl:call-template>
									</xsl:for-each>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
					<tr id="budgetContainerTr" align="right">
						<td id="budgetContainerDummyTd"></td>
						<td id="lineTableBudgetTd" align="right" width="200px">
							<span style="font-weight:bold; ">
								<xsl:text>Toplam İskonto</xsl:text>
							</span>
						</td>
						<td id="lineTableBudgetTd" style="width:81px; " align="right">
							<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount">
								<xsl:call-template name="Curr_Type"></xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
					<xsl:for-each select="n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Hesaplanan </xsl:text>
									<xsl:value-of select="cac:TaxCategory/cac:TaxScheme/cbc:Name"></xsl:value-of>
									<xsl:text>(%</xsl:text>
									<xsl:value-of select="cbc:Percent"></xsl:value-of>
									<xsl:text>)</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:for-each select="cac:TaxCategory/cac:TaxScheme">
									<xsl:text> </xsl:text>
									<xsl:value-of select="format-number(../../cbc:TaxAmount, '###.##0,00', 'european')"></xsl:value-of>
									<xsl:if test="../../cbc:TaxAmount/@currencyID">
										<xsl:text> </xsl:text>
										<xsl:if test="../../cbc:TaxAmount/@currencyID = 'TRL' or ../../cbc:TaxAmount/@currencyID = 'TRY'">
											<xsl:text>TL</xsl:text>
										</xsl:if>
										<xsl:if test="../../cbc:TaxAmount/@currencyID != 'TRL' and ../../cbc:TaxAmount/@currencyID != 'TRY'">
											<xsl:value-of select="../../cbc:TaxAmount/@currencyID"></xsl:value-of>
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
						<xsl:if test="cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode = '4171'">
							<tr id="budgetContainerTr" align="right">
								<td id="budgetContainerDummyTd"></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>KDV Matrahı</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:81px; " align="right">
									<xsl:value-of select="format-number(sum(//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal[cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=0015]/cbc:TaxableAmount), '###.##0,00', 'european')"></xsl:value-of>										
									<xsl:if test="//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID">
										<xsl:text> </xsl:text>
										<xsl:if test="//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID = 'TRL' or //n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID = 'TRY'">
											<xsl:text>TL</xsl:text>
										</xsl:if>
										<xsl:if test="//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID != 'TRL' and //n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID != 'TRY'">
											<xsl:value-of select="//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID"></xsl:value-of>
										</xsl:if>
									</xsl:if>
								</td>
							</tr>
							<tr id="budgetContainerTr" align="right">
								<td id="budgetContainerDummyTd"></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>Tevkifat Dahil Toplam Tutar</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:81px; " align="right">
									<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount">
										<xsl:call-template name="Curr_Type"></xsl:call-template>
									</xsl:for-each>
								</td>
							</tr>
							<tr id="budgetContainerTr" align="right">
								<td id="budgetContainerDummyTd"></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>Tevkifat Hariç Toplam Tutar</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:81px; " align="right">
									<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount">
										<xsl:call-template name="Curr_Type"></xsl:call-template>
									</xsl:for-each>
								</td>
							</tr>
						</xsl:if>						
					</xsl:for-each>
					<xsl:for-each select="n1:Invoice/cac:WithholdingTaxTotal/cac:TaxSubtotal">
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Hesaplanan KDV Tevkifat</xsl:text>
									<xsl:text>(%</xsl:text>
									<xsl:value-of select="cbc:Percent"></xsl:value-of>
									<xsl:text>)</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:for-each select="cac:TaxCategory/cac:TaxScheme">
									<xsl:text> </xsl:text>
									<xsl:value-of select="format-number(../../cbc:TaxAmount, '###.##0,00', 'european')"></xsl:value-of>
									<xsl:if test="../../cbc:TaxAmount/@currencyID">
										<xsl:text> </xsl:text>
										<xsl:if test="../../cbc:TaxAmount/@currencyID = 'TRL' or ../../cbc:TaxAmount/@currencyID = 'TRY'">
											<xsl:text>TL</xsl:text>
										</xsl:if>
										<xsl:if test="../../cbc:TaxAmount/@currencyID != 'TRL' and ../../cbc:TaxAmount/@currencyID != 'TRY'">
											<xsl:value-of select="../../cbc:TaxAmount/@currencyID"></xsl:value-of>
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:if test="sum(n1:Invoice/cac:TaxTotal/cac:TaxSubtotal[cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=9015]/cbc:TaxableAmount)>0">
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Tevkifata Tabi İşlem Tutarı</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:value-of select="format-number(sum(n1:Invoice/cac:InvoiceLine[cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=9015]/cbc:LineExtensionAmount), '###.##0,00', 'european')"></xsl:value-of>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode = 'TRL'">
									<xsl:text>TL</xsl:text>
								</xsl:if>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode != 'TRL'">
									<xsl:value-of select="n1:Invoice/cbc:DocumentCurrencyCode"></xsl:value-of>
								</xsl:if>
							</td>
						</tr>
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Tevkifata Tabi İşlem Üzerinden Hes. KDV</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:value-of select="format-number(sum(n1:Invoice/cac:TaxTotal/cac:TaxSubtotal[cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=9015]/cbc:TaxableAmount), '###.##0,00', 'european')"></xsl:value-of>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode = 'TRL'">
									<xsl:text>TL</xsl:text>
								</xsl:if>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode != 'TRL'">
									<xsl:value-of select="n1:Invoice/cbc:DocumentCurrencyCode"></xsl:value-of>
								</xsl:if>
							</td>
						</tr>
					</xsl:if>					
					<xsl:if test="n1:Invoice/cac:InvoiceLine[cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme]">
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Tevkifata Tabi İşlem Tutarı</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:if test="n1:Invoice/cac:InvoiceLine[cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme]">
									<xsl:value-of select="format-number(sum(n1:Invoice/cac:InvoiceLine[cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme]/cbc:LineExtensionAmount), '###.##0,00', 'european')"></xsl:value-of>
								</xsl:if>
								<xsl:if test="//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=&apos;9015&apos;">
									<xsl:value-of select="format-number(sum(n1:Invoice/cac:InvoiceLine[cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=9015]/cbc:LineExtensionAmount), '###.##0,00', 'european')"></xsl:value-of>
								</xsl:if>								
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode = 'TRL' or n1:Invoice/cbc:DocumentCurrencyCode = 'TRY'">
									<xsl:text>TL</xsl:text>
								</xsl:if>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode != 'TRL' and n1:Invoice/cbc:DocumentCurrencyCode != 'TRY'">
									<xsl:value-of select="n1:Invoice/cbc:DocumentCurrencyCode"></xsl:value-of>
								</xsl:if>
							</td>
						</tr>
						<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="211px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Tevkifata Tabi İşlem Üzerinden Hes. KDV</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:if test="n1:Invoice/cac:InvoiceLine[cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme]">
									<xsl:value-of select="format-number(sum(n1:Invoice/cac:WithholdingTaxTotal/cac:TaxSubtotal[cac:TaxCategory/cac:TaxScheme]/cbc:TaxAmount), '###.##0,00', 'european')"></xsl:value-of>
								</xsl:if>
								<xsl:if test="//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=&apos;9015&apos;">
									<xsl:value-of select="format-number(sum(n1:Invoice/cac:TaxTotal/cac:TaxSubtotal[cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode=9015]/cbc:TaxAmount), '###.##0,00', 'european')"></xsl:value-of>
								</xsl:if>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode = 'TRL' or n1:Invoice/cbc:DocumentCurrencyCode = 'TRY'">
									<xsl:text>TL</xsl:text>
								</xsl:if>
								<xsl:if test="n1:Invoice/cbc:DocumentCurrencyCode != 'TRL' and n1:Invoice/cbc:DocumentCurrencyCode != 'TRY'">
									<xsl:value-of select="n1:Invoice/cbc:DocumentCurrencyCode"></xsl:value-of>
								</xsl:if>
							</td>
						</tr>
					</xsl:if>
					<tr id="budgetContainerTr" align="right">
						<td id="budgetContainerDummyTd"></td>
						<td id="lineTableBudgetTd" width="200px" align="right">
							<span style="font-weight:bold; ">
								<xsl:text>Vergiler Dahil Toplam Tutar</xsl:text>
							</span>
						</td>
						<td id="lineTableBudgetTd" style="width:82px; " align="right">
							<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount">
								<xsl:call-template name="Curr_Type"></xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
					<tr id="budgetContainerTr" align="right">
						<td id="budgetContainerDummyTd"></td>
						<td id="lineTableBudgetTd" width="200px" align="right">
							<span style="font-weight:bold; ">
								<xsl:text>Ödenecek Tutar</xsl:text>
							</span>
						</td>
						<td id="lineTableBudgetTd" style="width:82px; " align="right">
							<xsl:for-each select="n1:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount">
								<xsl:call-template name="Curr_Type"></xsl:call-template>
							</xsl:for-each>
						</td>
					</tr>
					<xsl:for-each select="//n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate">
					  <xsl:if test="//n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate!='0'">
					<tr id="budgetContainerTr" align="right">
							<td id="budgetContainerDummyTd"></td>
							<td id="lineTableBudgetTd" width="200px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Döviz Kuru</xsl:text>
							</span>
							</td>
							<td id="lineTableBudgetTd" style="width:100px; " align="right">
								<xsl:value-of select="format-number(., '###.##0,0000', 'european')"></xsl:value-of>
								<xsl:if test="../cbc:TargetCurrencyCode">
								<xsl:if test="../cbc:TargetCurrencyCode='TRY' or ../cbc:TargetCurrencyCode='TRL'">
									<xsl:text> TL</xsl:text>
								</xsl:if>
								<xsl:if test="../cbc:TargetCurrencyCode!='TRY' and ../cbc:TargetCurrencyCode!='TRL'">
								<xsl:text> </xsl:text>
								<xsl:value-of select="../cbc:TargetCurrencyCode"></xsl:value-of>
							  </xsl:if>
							</xsl:if>
							</td>
						</tr>
					  </xsl:if>
					</xsl:for-each>				
					<xsl:if test="//n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount/@currencyID != 'TRL' and //n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount/@currencyID != 'TRY'">
						<tr align="right">
							<td></td>
							<td id="lineTableBudgetTd" align="right" width="200px">
								<span style="font-weight:bold; ">
									<xsl:text>Mal Hizmet Toplam Tutarı(TL)</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:81px; " align="right">
								<xsl:value-of select="format-number(//n1:Invoice/cac:LegalMonetaryTotal/cbc:LineExtensionAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
								<xsl:text> TL</xsl:text>
							</td>
						</tr>
							<tr id="budgetContainerTr" align="right">
								<td></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>Toplam İskonto(TL)</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:100px; " align="right">
									<xsl:value-of select="format-number(//n1:Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
									<xsl:text> TL</xsl:text>
								</td>
							</tr>								
							<tr id="budgetContainerTr" align="right">
								<td></td>
								<td id="lineTableBudgetTd" align="right" width="200px">
									<span style="font-weight:bold; ">
										<xsl:text>Ara Toplam(TL)</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:100px; " align="right">
									<xsl:value-of select="format-number(//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
									<xsl:text> TL</xsl:text>
								</td>
							</tr>
							<xsl:for-each select="//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
							<tr id="budgetContainerTr" align="right">
								<td id="budgetContainerDummyTd"></td>
								<td id="lineTableBudgetTd" width="211px" align="right">
									<span style="font-weight:bold; ">
										<xsl:text>Hesaplanan </xsl:text>
										<xsl:value-of select="cac:TaxCategory/cac:TaxScheme/cbc:Name"></xsl:value-of>
										<xsl:text>(%</xsl:text>
										<xsl:value-of select="cbc:Percent"></xsl:value-of>
										<xsl:text>)(TL)</xsl:text>
									</span>
								</td>
								<td id="lineTableBudgetTd" style="width:82px; " align="right">
									<xsl:for-each select="cac:TaxCategory/cac:TaxScheme">
										<xsl:text> </xsl:text>
										<xsl:value-of select="format-number(../../cbc:TaxAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
										<xsl:text> TL</xsl:text>
									</xsl:for-each>
								</td>
							</tr>
						</xsl:for-each>						
						<tr id="budgetContainerTr" align="right">
							<td></td>
							<td id="lineTableBudgetTd" width="200px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Vergiler Dahil Toplam Tutar(TL)</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:value-of select="format-number(//n1:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
								<xsl:text> TL</xsl:text>
							</td>
						</tr>
						<tr align="right">
							<td></td>
							<td id="lineTableBudgetTd" width="200px" align="right">
								<span style="font-weight:bold; ">
									<xsl:text>Ödenecek Tutar(TL)</xsl:text>
								</span>
							</td>
							<td id="lineTableBudgetTd" style="width:82px; " align="right">
								<xsl:value-of select="format-number(//n1:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount * //n1:Invoice/cac:PricingExchangeRate/cbc:CalculationRate, '###.##0,00', 'european')"></xsl:value-of>
								<xsl:text> TL</xsl:text>
							</td>
						</tr>
					</xsl:if>
				</table>
				<br />
				<table id="notesTable" align="left" height="100" width="800" max-width="800" style="word-wrap:break-word;">
					<tbody width="800" max-width="800" style="word-wrap:break-word;">
						<tr align="left" width="800" max-width="800" style="word-wrap:break-word;">
							<td id="notesTableTd" width="800" max-width="800" style="word-wrap:break-word;">
								<xsl:for-each select="//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
									<xsl:if test="cac:TaxCategory/cbc:TaxExemptionReasonCode!=''">
										<b>&#160;&#160;&#160;&#160;&#160; Vergi İstisna Muafiyet
											Sebebi: </b>
										<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReason"></xsl:value-of>
										<br />
									</xsl:if>
								</xsl:for-each>
								
								
								<xsl:for-each select="//n1:Invoice/cac:InvoiceLine/cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
										<xsl:text>Tevkifat Sebebi:</xsl:text>
										
										<xsl:value-of select="cbc:Name"></xsl:value-of>
										<xsl:text>&#10;</xsl:text>
										

								</xsl:for-each>
								
								<xsl:for-each select="//n1:Invoice/cbc:Note">								
									<xsl:value-of select="."></xsl:value-of>
									<br />
								</xsl:for-each>
								<!-- 
								<xsl:if test="//n1:Invoice/cac:PaymentMeans/cbc:InstructionNote">
									<b>&#160;&#160;&#160;&#160;&#160; Ödeme Notu: </b>
									<xsl:value-of
										select="//n1:Invoice/cac:PaymentMeans/cbc:InstructionNote"/>
									<br/>
								</xsl:if>
								-->
								<xsl:if test="//n1:Invoice/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:PaymentNote">
									<b>&#160;&#160;&#160;&#160;&#160; Hesap Açıklaması: </b>
									<xsl:value-of select="//n1:Invoice/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:PaymentNote"></xsl:value-of>
									<br />
								</xsl:if>
								<xsl:if test="//n1:Invoice/cac:PaymentTerms/cbc:Note">
									<b>&#160;&#160;&#160;&#160;&#160; Ödeme Koşulu: </b>
									<xsl:value-of select="//n1:Invoice/cac:PaymentTerms/cbc:Note"></xsl:value-of>
									<br />
								</xsl:if>
								<span style="font-weight:bold;color:blue; ">
									<xsl:text>e-Arşiv izni kapsamında elektronik ortamda iletilmiştir.</xsl:text>
									<br />
								 </span>

							</td>
						</tr>
					</tbody>
				</table>
			<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
				<table id="bankTable" width="800" align="left" height="50">
					<tr align="left">
						<td id="bankTableTd">
							<b>Banka Adı</b>
						</td>
						<td id="bankTableTd">
							<b>Şube</b>
						</td>							
						<td id="bankTableTd">
							<b>IBAN</b>
						</td>
						<td id="bankTableTd">
							<b>Açıklama</b>
						</td>
					</tr>
					<tr align="left">
						<td id="bankTableTd">
							GARANTİ BANKASI
						</td>
						<td id="bankTableTd">
							ŞERİFALİ ŞUBESİ
						</td>							
						<td id="bankTableTd">
							TR45 0006 2001 2620 0006 2956 91
						</td>
						<td id="bankTableTd">
							EKSPERT MEDİKAL ÜRÜNLER SANAYİ VE TİC.LTD.ŞTİ.
						</td>						
					</tr>					
				</table>		
			</body>
		</html>
	</xsl:template>
	<xsl:template match="//n1:Invoice/cac:InvoiceLine">
		<tr id="lineTableTr">
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cbc:ID"></xsl:value-of>
				</td>
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cac:BuyersItemIdentification"></xsl:value-of>
				</td>				
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cbc:Name"></xsl:value-of>
				</td>
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cac:ManufacturersItemIdentification"></xsl:value-of>
					<xsl:text>&#160;</xsl:text>					
					<xsl:value-of select="./cac:Item/cbc:ModelName"></xsl:value-of>
				</td>		
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cac:AdditionalItemProperty[translate(cbc:Name,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')='LOTNO']/cbc:Value"></xsl:value-of>
				</td>	
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="format-number(./cbc:InvoicedQuantity, '###.###,####', 'european')"></xsl:value-of>
				<xsl:if test="./cbc:InvoicedQuantity/@unitCode">
					<xsl:for-each select="./cbc:InvoicedQuantity">
						<xsl:text> </xsl:text>
						<xsl:choose>
							<xsl:when test="@unitCode  = '26'">
								<xsl:text>ton</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'BX'">
								<xsl:text>Kutu</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'LTR'">
								<xsl:text>lt</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'NIU'">
								<xsl:text>Adet</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'KGM'">
								<xsl:text>kg</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'KJO'">
								<xsl:text>kJ</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'GRM'">
								<xsl:text>g</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MGM'">
								<xsl:text>mg</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'NT'">
								<xsl:text>Net Ton</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'GT'">
								<xsl:text>Gross Ton</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MTR'">
								<xsl:text>m</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MMT'">
								<xsl:text>mm</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'KTM'">
								<xsl:text>km</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MLT'">
								<xsl:text>ml</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MMQ'">
								<xsl:text>mm3</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'CLT'">
								<xsl:text>cl</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'CMK'">
								<xsl:text>cm2</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'CMQ'">
								<xsl:text>cm3</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'CMT'">
								<xsl:text>cm</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MTK'">
								<xsl:text>m2</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MTQ'">
								<xsl:text>m3</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'DAY'">
								<xsl:text> Gün</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'MON'">
								<xsl:text> Ay</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'PA'">
								<xsl:text> Paket</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'KWH'">
								<xsl:text> KWH</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'ANN'">
								<xsl:text> Yıl</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'HUR'">
								<xsl:text> Saat</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'D61'">
								<xsl:text> Dakika</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'D62'">
								<xsl:text> Saniye</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'CCT'">
								<xsl:text> Ton baş.taşıma kap.</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'D30'">
								<xsl:text> Brüt kalori</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'D40'">
								<xsl:text> 1000 lt</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'LPA'">
								<xsl:text> saf alkol lt</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'B32'">
								<xsl:text> kg.m2</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'NCL'">
								<xsl:text> hücre adet</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'PR'">
								<xsl:text> Çift</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'R9'">
								<xsl:text> 1000 m3</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'SET'">
								<xsl:text> Set</xsl:text>
							</xsl:when>
							<xsl:when test="@unitCode  = 'T3'">
								<xsl:text> 1000 adet</xsl:text>
							</xsl:when>							
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="format-number(./cac:Price/cbc:PriceAmount, '###.##0,00', 'european')"></xsl:value-of>
				<xsl:if test="./cac:Price/cbc:PriceAmount/@currencyID">
					<xsl:text> </xsl:text>
					<xsl:if test="./cac:Price/cbc:PriceAmount/@currencyID = &quot;TRL&quot; or ./cac:Price/cbc:PriceAmount/@currencyID = &quot;TRY&quot;">
						<xsl:text>TL</xsl:text>
					</xsl:if>
					<xsl:if test="./cac:Price/cbc:PriceAmount/@currencyID != &quot;TRL&quot; and ./cac:Price/cbc:PriceAmount/@currencyID != &quot;TRY&quot;">
						<xsl:value-of select="./cac:Price/cbc:PriceAmount/@currencyID"></xsl:value-of>
					</xsl:if>
				</xsl:if>
			</td>
			<!-- <td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:if test="./cac:AllowanceCharge/cbc:MultiplierFactorNumeric">
					<xsl:text> %</xsl:text>
					<xsl:value-of select="format-number(./cac:AllowanceCharge/cbc:MultiplierFactorNumeric * 100, '###.##0,00', 'european')"/>
				</xsl:if>
			</td> -->
			<!-- <td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:for-each select="cac:AllowanceCharge/cbc:Amount">
					<xsl:call-template name="Curr_Type"/>
				</xsl:for-each>
			</td> -->
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:for-each select="./cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
					<xsl:if test="cbc:TaxTypeCode='0015' ">
						<xsl:text> </xsl:text>
						<xsl:if test="../../cbc:Percent">
							<xsl:text> %</xsl:text>
							<xsl:value-of select="format-number(../../cbc:Percent, '###.##0,00', 'european')"></xsl:value-of>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:for-each select="./cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
					<xsl:if test="cbc:TaxTypeCode='0015' ">
						<xsl:text> </xsl:text>
						<xsl:for-each select="../../cbc:TaxAmount">
							<xsl:call-template name="Curr_Type"></xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</td>
			<!-- <td id="lineTableTd" style="font-size: xx-small" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:for-each
					select="./cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
					<xsl:if test="cbc:TaxTypeCode!='0015' ">
						<xsl:text> </xsl:text>
						<xsl:value-of select="cbc:Name"/>
						<xsl:if test="../../cbc:Percent">
							<xsl:text> (%</xsl:text>
							<xsl:value-of
								select="format-number(../../cbc:Percent, '###.##0,00', 'european')"/>
							<xsl:text>)=</xsl:text>
						</xsl:if>					
						<xsl:for-each select="../../cbc:TaxAmount">
							<xsl:call-template name="Curr_Type"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each
					select="./cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
					<xsl:text>KDV TEVKİFAT </xsl:text>
					<xsl:if test="../../cbc:Percent">
						<xsl:text> (%</xsl:text>
						<xsl:value-of
							select="format-number(../../cbc:Percent, '###.##0,00', 'european')"/>
						<xsl:text>)=</xsl:text>
					</xsl:if>
					<xsl:for-each select="../../cbc:TaxAmount">
						<xsl:call-template name="Curr_Type"/>
						<xsl:text>&#10;</xsl:text>
					</xsl:for-each>
				</xsl:for-each>
			</td> -->
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:for-each select="cbc:LineExtensionAmount">
					<xsl:call-template name="Curr_Type"></xsl:call-template>
				</xsl:for-each>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="//cbc:IssueDate">
		<xsl:value-of select="substring(.,9,2)"></xsl:value-of>-<xsl:value-of select="substring(.,6,2)"></xsl:value-of>-<xsl:value-of select="substring(.,1,4)"></xsl:value-of> <xsl:value-of select="substring(.,11,6)"></xsl:value-of>
	</xsl:template>
	<xsl:template match="//cbc:IssueTime">
		<xsl:value-of select="substring(.,1,2)"></xsl:value-of>:<xsl:value-of select="substring(.,4,2)"></xsl:value-of>:<xsl:value-of select="substring(.,7,2)"></xsl:value-of>
	</xsl:template>		
	<xsl:template match="//n1:Invoice">
		<tr id="lineTableTr">
			<td id="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td id="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>			
			<td id="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>		
			<td id="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<!-- <td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td> -->
			<!-- <td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td> -->
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<!-- <td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td> -->
			<td id="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
		</tr>
	</xsl:template>
	<xsl:template name="Party_Title">
		<xsl:param name="PartyType"></xsl:param>
		<td style="width:469px; " align="left">
			<xsl:if test="cac:PartyName">
				<xsl:value-of select="cac:PartyName/cbc:Name"></xsl:value-of>
				<br />
			</xsl:if>
			<xsl:for-each select="cac:Person">
				<xsl:for-each select="cbc:Title">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:FirstName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:MiddleName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160; </xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:FamilyName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:NameSuffix">
					<xsl:apply-templates></xsl:apply-templates>
				</xsl:for-each>
				<xsl:if test="$PartyType='TAXFREE'">
					<br />
					<xsl:text>Pasaport No: </xsl:text>
					<xsl:value-of select="cac:IdentityDocumentReference/cbc:ID"></xsl:value-of>
					<br />
					<xsl:text>Ülkesi: </xsl:text>
					<xsl:value-of select="cbc:NationalityID"></xsl:value-of>	
				</xsl:if>
			</xsl:for-each>
		</td>		
	</xsl:template>
	<xsl:template name="Party_Adress">
		<xsl:param name="PartyType"></xsl:param>
		<td style="width:469px; " align="left">
			<xsl:for-each select="cac:PostalAddress">
				<xsl:for-each select="cbc:StreetName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:BuildingName">
					<xsl:apply-templates></xsl:apply-templates>
				</xsl:for-each>
				<xsl:for-each select="cbc:BuildingNumber">
					<xsl:text> No:</xsl:text>
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<br />
				<xsl:for-each select="cbc:Room">
					<xsl:text>Kapı No:</xsl:text>
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<br />
				<xsl:for-each select="cbc:PostalZone">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:CitySubdivisionName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>/ </xsl:text>
				</xsl:for-each>
				<xsl:for-each select="cbc:CityName">
					<xsl:apply-templates></xsl:apply-templates>
					<xsl:text>&#160;</xsl:text>
				</xsl:for-each>
				<xsl:if test="$PartyType='TAXFREE'">
					<br />
					<xsl:value-of select="cac:Country/cbc:Name"></xsl:value-of>
					<br />
				</xsl:if>
			</xsl:for-each>
		</td>
	</xsl:template>
	<xsl:template name='Party_Other'>
		<xsl:param name="PartyType"></xsl:param>
		<xsl:for-each select="cbc:WebsiteURI">
			<tr align="left">
				<td>
					<xsl:text>Web Sitesi: </xsl:text>
					<xsl:value-of select="."></xsl:value-of>
				</td>
			</tr>
		</xsl:for-each>
		<xsl:for-each select="cac:Contact/cbc:ElectronicMail">
			<tr align="left">
				<td>
					<xsl:text>E-Posta: </xsl:text>
					<xsl:value-of select="."></xsl:value-of>
				</td>
			</tr>
		</xsl:for-each>	
		<xsl:for-each select="cac:Contact">
			<xsl:if test="cbc:Telephone or cbc:Telefax">
				<tr align="left">
					<td style="width:469px; " align="left">
						<xsl:for-each select="cbc:Telephone">
							<xsl:text>Tel: </xsl:text>
							<xsl:apply-templates></xsl:apply-templates>
						</xsl:for-each>
						<xsl:for-each select="cbc:Telefax">
							<xsl:text> Fax: </xsl:text>
							<xsl:apply-templates></xsl:apply-templates>
						</xsl:for-each>
						<xsl:text>&#160;</xsl:text>
					</td>
				</tr>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="$PartyType!='TAXFREE'">
			<xsl:for-each select="cac:PartyTaxScheme/cac:TaxScheme/cbc:Name">
				<tr align="left">
					<td>
						<xsl:text>Vergi Dairesi: </xsl:text>
						<xsl:apply-templates></xsl:apply-templates>
					</td>
				</tr>
			</xsl:for-each>
			<xsl:for-each select="cac:PartyIdentification">
			<tr align="left">
				<td>
					<xsl:value-of select="cbc:ID/@schemeID"></xsl:value-of>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="cbc:ID"></xsl:value-of>
				</td>
			</tr>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	<xsl:template name="Curr_Type">
		<xsl:value-of select="format-number(., '###.##0,00', 'european')"></xsl:value-of>		
		<xsl:if test="@currencyID">
			<xsl:text> </xsl:text>
			<xsl:choose>
				<xsl:when test="@currencyID = 'TRL' or @currencyID = 'TRY'">
					<xsl:text>TL</xsl:text>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@currencyID"></xsl:value-of>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>		
	</xsl:template>
</xsl:stylesheet>
