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
													<xsl:text>Firma Tamamlayıcı No: 26672691150475</xsl:text>
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
										<xsl:variable name="vkn" select="n1:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID='VKN' or cbc:ID/@schemeID='TCKN'][1]/cbc:ID"></xsl:variable>
									    "vkntckn": "<xsl:value-of select="$vkn"></xsl:value-of>",
										
										<xsl:variable name="avkn" select="n1:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeID='VKN' or cbc:ID/@schemeID='TCKN'][1]/cbc:ID"></xsl:variable>
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
								  <img style="width:240px;" align="center" alt="Company Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAIhBMcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigApCKKq6nK0OnXUinBWNiD7gGmldpEylypy7FgMGGRgj2NKa/Pvw/+1b428H+KpZp501bTUlKy6dOAolAPJV+qNgHBwRnGQe32t8OPil4d+Kmif2l4fvluVXC3Fu3yzW7kZ2SL2PvyD1BI5r2MdlOIwCU5q8X1R8/lueYTM5Sp03aS6P8AQ7Cikpa8Y+iCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooATvVDXDjR789vIf/wBBNX+9UNe/5At/2/cSc/8AATVw+NeplV+CXoflTrSkaxejAJMrdBnPI/l/Wr3g3xtrPw/8QQa5oWoSadew5BK5McqHrHIhwHU4B2noQCCCARS1pidYveoxMwx3zk8/yP4VSUkDGO4PU4H6Y4B6Cv39U41aKhNJprY/l11Z0cQ6lN2kn+p+i/wQ/aB0b4u6ZDbvJDYeJI4w1xp4clW7F4mIG5fbqvQ9ifWc1+Sun3lxpt5b3VrcSWs0MiyxzQylHRlYEMpByCCAQe30r7A+BH7YUGrSQ6B4+njs71vlt9cO2OCY5xsmAwI36YYAK3P3TgH8zzfh2eHvWwqvDquq/wCAfsGRcVU8XbD4x8s+j6P/ACZ9WUUgIYZByKWviT9HCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBBVHXv+QLf/APXB/wD0E1eFZ/iA7dC1E+lvIc/8BNXD4l6mVX4Jeh+VWuDOr3oJyDMwJPoSeelUgc4IGfoODjFXtdGNXvQeAZXzznjJB4qkSxzkgnByR1PuO30x6iv6Cp/BH0P5Yrfx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bi0Y5IEiAnGcHDAlTg4Jwa/I80yatlsub4oPZ/5n7tk2f4fNY8vw1Fuv8ju6KKK+fPqgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/WszxL/AMi9qf8A16yf+gmtM/1rM8S/8i9qf/XrJ/6CauHxr1Mav8OXoz8rtdz/AGzf55HnuQQePvHj+X0zVHkAbSBjnDcDPGfp9Pb8ruunbrV8OSRPIcj03E4zniqIG0AjAz0wDjHtX9BU/gj6I/lmt/El6scPlYZBOSAVyCc9cHOPfp+VIBtyMYY4HA46f4UALkjII6Accc9MfmaVSQ3IJPXGSR69+3+PvVmA3gYxySM9euecZ68/X0oB3An5cdDx+Ayffj8qAB3IIIxn+Z5HOBSqW3A/MDk5HTPfPvnH8verBbigHftPBxjAOSeeSP06e/1pow3Q4JGOoxk85/LB59qOBgk8A+nX/Hgdh+dBYgn3OcZ4/r6Y/A4zQAA7iDgY7HI9yOv1NGOcEdcfnxx/P/PNGQWPIGB1Uk9xkfTBFLknrtJJAJ/Tn17VACFuDnOD14ye+Oenc/l+Wv4W8Wax4J1yDV9Fv5tM1GHgXEXUpkEqwPysmcZVgQcZxnmshWyoOM8bsdiQCB+lBHGAMkZAAzyPQZ79T+FTOEakXCaTT3TNaVSdGaqU3ZrqfoN8Bv2l9I+LEUOlaiItI8VhCWsyx8u5C9XhJ68clCSyjP3gN1e2H86/JBJ3hlWWKV4njYOksTsjowOQysuCGB5BBBBxivrz9n/9rb7QIPDvjy5VZ94itdbPyqwwMLcdlYHI8zhSMbsEEn8yzfh6VC9fCK8eq6r07o/ZMh4qjibYbGu0uj6M+taKarBwCCCDzxTq+GP0rcKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBPSs3xL/AMi7qX/XtJ/6Aa0vSs3xJx4e1I/9O0n/AKCauHxr1Mav8OXoflbrWRrV9gY/fuRznPzH8+cVQ9epycHGMnoP6Cr2uAf2xegEE/aJDj/gWQPrVFSMg4B5656/j7569a/oKl8MfRH8sVv4kvV/mJkqCT14yOuRnIzTvuEEEDng9O/T64Ht+dJglQD6YzySPfj2oDEtgcc+vAGeff8A+titjEUZzgjGTkkDjjHIHUn+tIoHpkdODjnuMDv9O9IvA4JOARkdccZ6fX+VLkKGPQD1HX3yOw4+lACjPBHTvweuT744xRkgg5wcgEE56DPU9+evf8aMbSTgKQSuepwD/jn8evNA+UA4OM8AgnoePoM4Pp0oATJGCDzjsecdcc45z36UYyQAR6DrkHpkUAAZHAIzgEZ4wAef89DSrjdwCDweBg9/QZ78Zx9KgBM56HPORkY5J6epyP0xQpBPygHvnOR3/DjB9/50KR8pAyOc9+OOxH+c0DICknPbk9Tj0HX8PTirGKTkHOc47nr6c59fXmhGKnKkAEkBuMEHqOvp29D+aD5uMZHQe4H4cc9evT8lySDjAU5PJwOeB+px65zQHoe6fAj9qLVPhdImj64J9X8MDbGkI5uLLnGYycbkx1jPIxlT1B+5/DHinSfGmg2ms6Hfxalpl2u+G5gbKtzgg+hBBBBwQQQQCCK/KQMByDyvAJPbnPX8P84rs/hV8XfEPwg17+0dEnElnI3+maXOzfZ7pfcDJRwOkgBI6EMMg/E5vw/DFXrYbSfVdH/kz9DyLimpgrYfFvmh36r/ADR+n2eaP0rhPhN8YNA+MGgm/wBHmMdzAQl3YTYE1s5GcMO4PUMMg9jwQO7xjmvy6pTnSm6dRWaP2ijWp4iCqUneL6jqKKKzNwooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/AFrM8S/8i9qf/XrJ/wCgmtM/1rM8S/8AIvan/wBesn/oJq4fGvUxq/w5ejPyu1zI1q+wTkzuAc8nkjt6/wBKocgEknJGBk4/H/OOlXtbymr35JP+vckknj5j/Lr/AI1SXsDk8kcHoc4Pb3r+gqf8Neh/K9b+JL1YhzhsEk8nnJIHpz9OlBYDJ/hHPTJAHvxz+lO3YORwB0Ax+JB9sH/JFIDhs53Ht2HtjjrjP5VsZCYK8ZwRwCOCO/07Zx+lLnacgEgHAyc9uAD9KQAAjAIGOcg8dR3/AJ0KcEnocAnHU845H+evvQAbeMDoCBnOfbHf3pdvzYwSoGM569D7/Q96QAbuDz0AwO564HUe/qaOjDKjsQDjPfsM0AA4JIUDPYc++M898fkKaByDgYBIODk98n888Dt6UowCSMZx1H4nOffP8vpS7icjJB5GCMH9PT0oABkkEg5zg9x3xSAkqADk4xwQeOM8/wCPb0pRkMMEBhwODnr/APqGfQ0nJwSQp65IAx15/l9MUAKOeAvoQcE8fl6YPr2oGcYxk9fbPt/nkj2oBG4emQDwc9CQD7c9+4xz0oAwFyAD6DGDwc4B6445+nSgAAypGOMEEAHH4/55BFLyc889eeTnn09s/lmkADAdgBnOBx0xjuO2SfSjkgZBOBnJwAPXjtx9fwoA2fC3irV/BGu22saJfS6df2zHbLGeCD1RlPDKePlYHOAeCAR9+/AL4+6d8ZdGMExisvFFnErX2noSFIPHmxZ5KE9uSp4P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9Tz+Z9Kbwc52+5JxgA9D+OBS84IGSc8HJIJPcduw6e3NBUDIHK8gYx06c9unamgAg5Jwc5ye2Tnkd+fXrikAG3jjoMAk8A/ywaANxzgDODwOMelKCG64J6jcDk9Tx6+nXrVDPT/2XD/xkL4IIwc3F1kA9P8AQbmv0kFfm5+y8Qf2g/AmARm5ujzjP/HjdenB/wDr1+kY6mvyfiv/AH6K/ur82fuPBP8AyLpf4n+SFooor4w/QQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGjp+NZviT/kXtT/69pP/AEE1pDp+NZ3iNd2gakPW2kH/AI6aqn8a9TGt/Dl6M/KvWh/xOL3dlR58nQnPU9/Tpx3qlndyFIJGcAdOO1XdbI/tm9xkjz2B5z/EcjHT+vWqR6HAx1BAHtX9CU/gj6H8s1v4kvVhnJI69D0OTnPPuKO/pk88EjrjGOv4fj1oYHO0nAzjI9P69eMAfhRnJXOSD0498Y/Dj8CK1MUAGB8xHtnOPUj+h+oowCeM8Y5B5xn6d/8AGgAqoBBAzjpwenOB+P8AgMUhztIzhgDx0GcZ59cYH+c0CHBiCDngckgAd+OfX6f/AKk2kDByR0yRxjrn9APT8aOVGRuAxwepx179epoxjOTgkgE4/wD1DIHX60ABwWJPI688579fX1zQepGTgjGTgZ6/r9M9aQgMpIABI7LnH6DsP1HpTlB7DJ6kgdRk/njNTcBqgYHoccg5GSec/h+mfSgMcAnggHljk/8A6x6f4UYwOSCSMkA8HH5cEHng0pBByMnn0Jz6A5+n6VQCfiTweBwCfpzzk9ewpSDnOcN1BAwM8gds9zwPxoBxjkjnGenYHIz05Of60c5IAJA5IIz78c9O+PwoAQD5SDx9Dnk//qpSMEEZJwSCRyMf/X96QIAf73Xg8j8z34//AFUnPclgBgkHg46/nn68fjUoNwUjAGB1AJyD+RHHP9D9KXAJJzk9OfTHXJ/DmlJPJz6kcYyM/wA8/wCetISQCCMEAjJHB4/yfxqikeofswAD9obwKfW6usdP+fC5/LpX6SDpX5u/svj/AIyF8DDA+W4ujkf9eNyP8/Sv0jr8m4r/AN9j/hX5s/ceCv8AkXS/xP8AJBRRRXxp+gDSeKOtH1OKwdf8a6N4at/Ov71EUnAVMufyGcfU1UYSm+WKuZzqQprmm0l5m9096Bn2rxrxJ+0dp2n3KxaZa/boyMmVn246cAYx365rzfVvj74ru7pntL/7FCTlYlgjIA9MlST2716tHKsTVV7W9Twa+fYOg7X5vQ+rc0ZNfL/hz9o3X9NlYaoY9VjOcBo1jKjtyoGPxBr1PwZ8edA8TLHDfMNEvpGKpFcyAxvzxtk4HpwwBycAGor5biaCbcbpdjTDZ1g8S1FSs/P+rHp9FICCAQcilryz3gooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKr3kC3VpNE33ZEZD9CMVYpMCmnZ3JaurH5OeIbSay1i7S5RonWeRWRuCpDlTx16g9R196oAc44A6EnoTxwR6epPv7V9A/tk+ERoHxCt7i2tXitr6KS78xUO1nLASc4xkE5IzxuB718+5BAGQATz1B74/l+tfvOX4mOLw0Ky6o/mTNMLLBYypQl0YnKnAGCexJz64J7/j9KUEDBGGA43e4Gceh4I49fpmhcgZyB2AU9O2c9fz9+1JuAIHfIOO4A5zj0616J5IFQASclSMgg8YyP/rUpJYgZwSc4HcZ6j1xz+eKNu0YIA9DgjPQgDHGeP8AOKTOSATg/TgH0PfJ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QHOSBgMcEnGM9ufQ9OPYetIcDIwx69eB+Z6f40gBOcgHOR0wR+nHAP50obAJBHqefX3HX8KBnQ/D/wD5HbShknmUE8gkGJ85/X15wOnT1wA5UDknnPAB4wMg4yPy715B4AUJ410nA6NJwSc/6mTtg+3+eT69tBTAAIweoA5B6+3ABP0968DH/wAVeh9Dl/8ACfr/AJDlIHBwMADocH0Pb27/AMqFztA5z04ORk9CMjI7jv8AzpMEcAjkjgcYPJz07fp9KARkDCggDOBnGTwCB9OnvXlnqXAfNggBlOMkHjHYH8OMf/WyoXDAjnHQ/p14J7Yx60n8QI5Y5AIAJ9QO/AyfypQTkHPIORgkBvTn6Z9+hoAQkIPlyBjGDzgc5+oIOe3fvTjkMckjkdRx268nPI/A5+tJt3EcZ7AjkdwevsaANwwT8uRyT1zx1P5fWncSA85HJOBnJ68+p/D/AOv1o4BIJAUDBwBwPqe3Sk2jJZs5ABPPJ9Ce3pj0zTud2CGOSOM9TnqTzwf5/SkMaCeDkZGCAozk4yOfUHsOacBtyM5xxkcjjnPXoOKQHOSG4A5JOQT17e3fjk045GQe3UkEHgAnHbqfTv70/ILFzSNWv9A1CK/066e0vYifLnQglQeoIPBBwMggg+nSvpH4YfHKw8YNFpmq7NM1knbEpb93dH1Q9m9UPPpkZx8wnO45ABzwAM44A4Azk4/pTSofIPIBPGcEdxjuCCOCORjPpXnYvA0sXH3lZ9z1svzOvl87wd49Ufe3Wg8184/Cv49zaU0WleJ55LmzAVIdQYFpo+373u6/7YyRj5s8kfRFtcRXcEc0MiywyKGSRGBVgeQQR1FfB4nCVcJPlqI/UsDj6OPp89N69V1RYooorjPTCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGgUtQT3UNpHvnmjiUfxOwUfn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HJAY8jGfb064/WgAwuTkDgYJbkjn8eOcnJpSSTk5BYcg5546H1H59eaTIzwAMDgZ9DwB6dvagAEsABtyeMHgd+3HPp6fjQFwJJIAOR65yccke46HPP6UDPbg5OM8n64/D9elOJPJfhjjJyMA9jg/y/GmrjK8qOpBHXqTwfzFABtBYZClegA9OOCQPrke1AO4gHgkjJJA7dM54HXnHNJuA24Iz/tYXPfj8genp68KMhlOOd2AeM9Ccc8Dkk56dck44AFJJXGTk9DnByenr7c9uKUc5IA7dzz1xk/T+YpqklQR90jqMADjnHbr707ALYwAG46HA5z6dvQdfyNAIQ8E5XI7AkZ4/r7ewqSCeW1uY5IpHhmikDo8bFXVgcggg5BHGCOaiJwoIBBwcA8HnjOOmMfrRkbjjoDjGQBxjjPrn+ZzSavoxptO6PfPhj+0GsjR6X4ukS3lPEWq4CRvyAFlH8Dc/eHynvtOM+8Bgygg5FfBPXcpAIJwVJ4IOODkemeO9emfCr4z33gh4dO1Fn1DQM7VXO6W1HYocncn+x2BG04G0/LY/KU06uHXqv8AI+3yrP3Fqji3p0f+f+Z9VUDn6VnaLrlj4j0y31DTrqO8sp13RzRnIYf4g8YPQ5BrRAr5Jpx0Z+gxkppSi7odRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAaBSZ5rzb4rfHXQvhTA6XY+1aiBuS0D7N3AP3iD6jsetfP+uft0Xt3ayx6doq2UzA+XIriUr05O4AH8q9jC5RjMZFTpQ93ufP43PcBgJOFap7y6I+yunfFULrX9OslYz31vGV6gyDNfnve/tUfEK6Zx/bR2SAgq0ak85zwAABj2rzrVPFer6vc+fdX85csSQrFRz1PHHP9DX0VHhStJ/vZpLyPlMRxth4q1Cm2/PQ+/PEf7U3gXQftkK6j9ovbclRBtK729Acf0rxXxJ+3Ff3du8Wl6SLGU9JQ4f6feH64r5WLM7A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Kw4x34/TrzXMFd31Poc/56ikB+YjH1x2/wAM0+WxtGnBdC/ea7qV+CLi/nZSMFA+xcEdMLgY61QRFHIAGe+MdvWlwQcdOuO3+c0cAHIzjqCP0/XpVWNfJAOSM4J9T649OaQqAOgPuPX6/pTumOM+/wCPY/lQD0PGevNUK43ueScc5Hf/ADmpI3aCeGaN2jkhdZY5ImKtG6kFXUjkMCAQRyCKZzx2wSOKRhkkY69s98cmoaTVmXFuLTi7NH6u/sefHWX44fCiCfV7mGXxXpEn2HVRGFUysBmO42A/KJEwTwBvEgAAXFe79K/L3/gn341m8NftEw6MZJBa+I9MntHhVsK0sI8+JyO5VFuFH/XQ1+oNfh+d4JYHGyhFe69V6M/dslxjxuChUlutH8h1FFFeEe6FFFFABRSDmq15qVrYAfabqG3B6GWQLn8zTSb0RLaW5aoqlaavZX7Fbe8t7hhyRFKrH9DVwmhprRgmnsLRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGnmvFPj9+zZpnxdtJdS09otM8UxxFYblwfJuCB8qTAAnHAG8Aso/vAba9ro610YfEVcLUVWk7NHHisLRxlJ0a8bpn5R+LPB+ueBNdn0XXtOm0vUI1BMcoysino8bj5ZFOCNy8A5BwQQMc46HIKnA4+6O/b+f8uK/U3x/8N/DvxN0b+zPEWmQ6hbq2+J2+WSB+zxuMMrdsgjIyDkEivkH4h/sO+J9AkkufB+ow+JbEAkWWoSLb3i8jCh8eW56kk+XwMc1+n5dxJQrpQxL5Jfg/wDL5n45m3CWJwsnUwi54duv/B+R84A5XhSMDA5PTrjPTHP8/egHHTj1JGDz6/pyD3+tbXiPwD4q8GtcDXfDOsaYkDbXnnsZTBnnOJkDRkY6ENiuaOp2IYgXtuCOCTKA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" />
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
									<img style="width:180px;height:150px;" align="middle" alt="Imza Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwYHBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAz/wAARCAL8A8kDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9/KKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAPnj/gpf+3rp/8AwT5/Z1uPFk2ny6vrF/L9g0axX7s92ykoHOQQnHJHNfkN8Af+DgD9oDTv2mfC1p4h1+w8XaP4l1j7LPoC2ENvJYrITtVXVAxC5GCTk45rqP8Agvd+1bafF79sGHw7Z3V9deH/AIf2ptry2TIj+3EnecY5IQgZr57/AOCNP7NMn7Rv7Wt74+eB5PD/AIMlZYlZctPdN7Cv0jBcP4WjkrxmKXvyV1fouhzuq/acq2P6RPAPjGDx74UtNUt1ZI7lAcN1B71sVz/wu8KR+C/A1hYRFiiJv+bqC3OP1roK/NzoCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKK8J/a3/4KC+Bf2QXjtdduHu9Ultpbv7JbspeKKNcs75ICj6149/wSs/4LP8Ahj/gpxqvibTLDw/f+HdT8NsjOs7K0c8bjgqQSc5rq+pV/Ze35Xy9+gH2vRRRXKAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAVwv7Sfxu0z9nb4J+IfFuqXlnZxaTZySwm5kEaSzBSY48nuzYA+td1X5W/8HIf7V8Og+GfDHwqia0lg1cnWdSfefMtxbuNq4993f0r08my+WNxkMOur19OpM5cqufj3+2X8ZNQ+I/xC8T+K7zMeoeKNTbUp4o/uxl+wr9ov+De79kq7+En7NuiTaxA9rqN4Brc/wAuVleTI21+Q3/BOr4b6J+03+13o3hfX7SbUYop/wC17iPzf3cSRV/T38B/AFv8OvhtYWNuF8tk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wd1vwxommW+gyarbtEtwlvGxiJ9AFH86/FjUf+Ddn9pTTPjLP4amutHTw0919nfWIpHaU23+woGO9f0r0m0E5wM16mA4qzDCxlBT5k++ocqPjz/gm/8A8EpvC/7D3gyztbG3RbiPEks3/La4k7Mx9PavsSiivCxGIqV6jqVXdsdgooorEAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiivPP2qP2jvD/7J/wACtf8AHXia7+x6Xo1uW37C+ZCCI1wPVsCqhCU5KEVdsD8kf+Dnz9su91Px94Y+DWh6ujaStudU8QW6DmKSOQeWCcehzXG/8EGP2Jb6TXF8WeIdNkt5PErCC0kQZkitj3PpXxl408beLf8Agpz+3DcazeWcQuvGt9HcXSWwwtlaoAOPyr+iv/gn98DIfhf8M7W4aCa3uEt1solJIjMKgbSB/Wvt81q/2fl9PA0/ikveJpu7cj3zR9NTR9KtrSPlLaJYgcYztAGf0qzRRXwxQUUUUAFFFFABRRRQAUUUUAFFFFABX5Ff8HLfxgsfFXi34W/DSORor2xv21i5PZo5ImjQfmDX661/OV/wWG/aktP2h/27PFGuaVM6QeHLVdEtlXqZ4WeMn8WJr6bhTCurjfaW0gmzKrK0T6X/AOCK/wAL/wDhcfxr8S+KJoY4FiuItIsJ8ZxHFHucfjiv2ciTyolXP3QBX53/APBLvXfh1+wd+zZpOn/EHxN4a8M6sbYX9w9/exwkzyAl8FyOSB0FeAf8FL/+DlCOLSbzwb8BbYy396pjl8R3kZHlxnIYW8JALOQcrJuwpHQ0YjL8VmWPlGjB72u9l6stS91Mt/8ABxR/wVRs9F0z/hS/grW5472Ri/iC5sypGxchrNsjOTkE4/OvwzvNYee8jvI/KroPHOoeJfFvi+/1jXdSvtT1nUJDd3t9euXlnc9WZjyTXLalC8+y3s/3t1M/lR/9NX+5X6/kWVUsswyoWu3q33Zzyld3Ow0fffeG5LyN5ZpYXTzKfrHg+G+hg1C81KWW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nMbw34m/bh/aVGlWcktxd61dm4vrgDHlxMcyPj6mvVf+Cnf7b2rftcftE63MNSuZrCGY2emROACsYJ2jA479a+6f+CG3/BNSTwHpEOsazH5uo6owudQkTH+jxjmJOfpX6JhoQybAOpP+JNGE487PuX/gmz+x7pX7PPwn0l4rTyjbWwhsxvPyIRhgy+ua+oajtbZLO2SKNQqRqFAAwOKkr8+rVZVJuct2dDYUUUVmIKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/CL/g53tY5f22fCcszbI4vDC5P/AG2avqP/AINrr23m+CevJC2QjBf/AB+vA/8Ag6m8CXQ+KHw88QpCfs8kJsTN2DZLYrvv+DZDxBJp3ws1dJTg6nqskY98EmvtcdFSyKjJdP8AMmG7P14ooor4ooKKKKACiiigAooooAKKKKACvzR/4L+/t3H4V/DFPh/4fuZDrGrjfNLazAlE5BjYDkZr7q/ag/aI0X9mP4Sah4n1u4aCGACOIqoY+Y2QvHpmv5r/ANq74j+If25P2r7z7FcCfUvFGomKLyekK+1fS8N5cq1b29X4I/mRN9Do/wDglj+ytP8AtCfHiLXr/T5LzSNEuN6RlSzXl37Ada/o5+AnwltPhP4GtrWNI2u5kEk0wj2u+eQD9K+Y/wDgk7+xBpnwG+EmjTmDJ0+PbE24qxmB5cjuCDX2pXPxBmjxmJbT91aItKwUUUV4QBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUA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RRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABXO/FP4V6H8ZvBN94e8RWEOo6XqEZimikUEEH610VFNNp3QH4Uf8FMP+DX6z8G31/49+DVxexW6O91c6NFliCeflHJYfQcV4J/wTv1T4j/ALPmqzahZwyeE9E8P3nm38t9kGTnofbiv6UXQSKVYBlYYIIyCK+RP+Cgf/BKDw7+2T4fddP1C68OXsjZlS1fyopye5xnb07CvqcFxE3T9hjFzR7/AOYz8fP2vv29/i9/wU/+K9r4J0ae7l0aCULFZwgpbgD71zKMnJA4FfeX/BK3/gjIPhZLbeJvEl5PcSsBnK7fMT+6uenY55Fe8/8ABPH/AII8eFv2NdEkOoiHVtTlm82STJdZm7MxOM/QjFfaMFvHawrHEiRxoNqqowFHoBXPmGcxlD6vhFywJ5UiLStLg0XTobW3QJDAgRR7AYqxRRXzowooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//9k=" /><br />
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
											<xsl:text>Lot - ÜRT - SKT Bilgisi</xsl:text>
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
							G.O.PAŞA ŞUBESİ/İSTANBUL
						</td>							
						<td id="bankTableTd">
							TR51 0006 2000 0700 0006 2942 68
						</td>
						<td id="bankTableTd">
							İDEAMED SAĞLIK HİZMETLERİ TİCARET LİMİTED ŞİRKETİ
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
					<xsl:value-of select="./cbc:Note"></xsl:value-of>
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