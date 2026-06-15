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
				<title>e-Fatura</title>
			</head>
			<body style="margin-left=0.6in; margin-right=0.6in; margin-top=0.79in; margin-bottom=0.79in" max-width="800">
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
											<xsl:text>e-FATURA</xsl:text>
										</span>
									</h1>
								</td>
								
							<td width="20%" align="center" valign="middle">
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
								<div width="40%" align="center" valign="middle">
								  <br />
								  <img style="width:240px;" align="center" alt="Company Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAIhBMcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigApCKKq6nK0OnXUinBWNiD7gGmldpEylypy7FgMGGRgj2NKa/Pvw/+1b428H+KpZp501bTUlKy6dOAolAPJV+qNgHBwRnGQe32t8OPil4d+Kmif2l4fvluVXC3Fu3yzW7kZ2SL2PvyD1BI5r2MdlOIwCU5q8X1R8/lueYTM5Sp03aS6P8AQ7Cikpa8Y+iCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooATvVDXDjR789vIf/wBBNX+9UNe/5At/2/cSc/8AATVw+NeplV+CXoflTrSkaxejAJMrdBnPI/l/Wr3g3xtrPw/8QQa5oWoSadew5BK5McqHrHIhwHU4B2noQCCCARS1pidYveoxMwx3zk8/yP4VSUkDGO4PU4H6Y4B6Cv39U41aKhNJprY/l11Z0cQ6lN2kn+p+i/wQ/aB0b4u6ZDbvJDYeJI4w1xp4clW7F4mIG5fbqvQ9ifWc1+Sun3lxpt5b3VrcSWs0MiyxzQylHRlYEMpByCCAQe30r7A+BH7YUGrSQ6B4+njs71vlt9cO2OCY5xsmAwI36YYAK3P3TgH8zzfh2eHvWwqvDquq/wCAfsGRcVU8XbD4x8s+j6P/ACZ9WUUgIYZByKWviT9HCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBBVHXv+QLf/APXB/wD0E1eFZ/iA7dC1E+lvIc/8BNXD4l6mVX4Jeh+VWuDOr3oJyDMwJPoSeelUgc4IGfoODjFXtdGNXvQeAZXzznjJB4qkSxzkgnByR1PuO30x6iv6Cp/BH0P5Yrfx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bi0Y5IEiAnGcHDAlTg4Jwa/I80yatlsub4oPZ/5n7tk2f4fNY8vw1Fuv8ju6KKK+fPqgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/WszxL/AMi9qf8A16yf+gmtM/1rM8S/8i9qf/XrJ/6CauHxr1Mav8OXoz8rtdz/AGzf55HnuQQePvHj+X0zVHkAbSBjnDcDPGfp9Pb8ruunbrV8OSRPIcj03E4zniqIG0AjAz0wDjHtX9BU/gj6I/lmt/El6scPlYZBOSAVyCc9cHOPfp+VIBtyMYY4HA46f4UALkjII6Accc9MfmaVSQ3IJPXGSR69+3+PvVmA3gYxySM9euecZ68/X0oB3An5cdDx+Ayffj8qAB3IIIxn+Z5HOBSqW3A/MDk5HTPfPvnH8verBbigHftPBxjAOSeeSP06e/1pow3Q4JGOoxk85/LB59qOBgk8A+nX/Hgdh+dBYgn3OcZ4/r6Y/A4zQAA7iDgY7HI9yOv1NGOcEdcfnxx/P/PNGQWPIGB1Uk9xkfTBFLknrtJJAJ/Tn17VACFuDnOD14ye+Oenc/l+Wv4W8Wax4J1yDV9Fv5tM1GHgXEXUpkEqwPysmcZVgQcZxnmshWyoOM8bsdiQCB+lBHGAMkZAAzyPQZ79T+FTOEakXCaTT3TNaVSdGaqU3ZrqfoN8Bv2l9I+LEUOlaiItI8VhCWsyx8u5C9XhJ68clCSyjP3gN1e2H86/JBJ3hlWWKV4njYOksTsjowOQysuCGB5BBBBxivrz9n/9rb7QIPDvjy5VZ94itdbPyqwwMLcdlYHI8zhSMbsEEn8yzfh6VC9fCK8eq6r07o/ZMh4qjibYbGu0uj6M+taKarBwCCCDzxTq+GP0rcKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBPSs3xL/AMi7qX/XtJ/6Aa0vSs3xJx4e1I/9O0n/AKCauHxr1Mav8OXoflbrWRrV9gY/fuRznPzH8+cVQ9epycHGMnoP6Cr2uAf2xegEE/aJDj/gWQPrVFSMg4B5656/j7569a/oKl8MfRH8sVv4kvV/mJkqCT14yOuRnIzTvuEEEDng9O/T64Ht+dJglQD6YzySPfj2oDEtgcc+vAGeff8A+titjEUZzgjGTkkDjjHIHUn+tIoHpkdODjnuMDv9O9IvA4JOARkdccZ6fX+VLkKGPQD1HX3yOw4+lACjPBHTvweuT744xRkgg5wcgEE56DPU9+evf8aMbSTgKQSuepwD/jn8evNA+UA4OM8AgnoePoM4Pp0oATJGCDzjsecdcc45z36UYyQAR6DrkHpkUAAZHAIzgEZ4wAef89DSrjdwCDweBg9/QZ78Zx9KgBM56HPORkY5J6epyP0xQpBPygHvnOR3/DjB9/50KR8pAyOc9+OOxH+c0DICknPbk9Tj0HX8PTirGKTkHOc47nr6c59fXmhGKnKkAEkBuMEHqOvp29D+aD5uMZHQe4H4cc9evT8lySDjAU5PJwOeB+px65zQHoe6fAj9qLVPhdImj64J9X8MDbGkI5uLLnGYycbkx1jPIxlT1B+5/DHinSfGmg2ms6Hfxalpl2u+G5gbKtzgg+hBBBBwQQQQCCK/KQMByDyvAJPbnPX8P84rs/hV8XfEPwg17+0dEnElnI3+maXOzfZ7pfcDJRwOkgBI6EMMg/E5vw/DFXrYbSfVdH/kz9DyLimpgrYfFvmh36r/ADR+n2eaP0rhPhN8YNA+MGgm/wBHmMdzAQl3YTYE1s5GcMO4PUMMg9jwQO7xjmvy6pTnSm6dRWaP2ijWp4iCqUneL6jqKKKzNwooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/AFrM8S/8i9qf/XrJ/wCgmtM/1rM8S/8AIvan/wBesn/oJq4fGvUxq/w5ejPyu1zI1q+wTkzuAc8nkjt6/wBKocgEknJGBk4/H/OOlXtbymr35JP+vckknj5j/Lr/AI1SXsDk8kcHoc4Pb3r+gqf8Neh/K9b+JL1YhzhsEk8nnJIHpz9OlBYDJ/hHPTJAHvxz+lO3YORwB0Ax+JB9sH/JFIDhs53Ht2HtjjrjP5VsZCYK8ZwRwCOCO/07Zx+lLnacgEgHAyc9uAD9KQAAjAIGOcg8dR3/AJ0KcEnocAnHU845H+evvQAbeMDoCBnOfbHf3pdvzYwSoGM569D7/Q96QAbuDz0AwO564HUe/qaOjDKjsQDjPfsM0AA4JIUDPYc++M898fkKaByDgYBIODk98n888Dt6UowCSMZx1H4nOffP8vpS7icjJB5GCMH9PT0oABkkEg5zg9x3xSAkqADk4xwQeOM8/wCPb0pRkMMEBhwODnr/APqGfQ0nJwSQp65IAx15/l9MUAKOeAvoQcE8fl6YPr2oGcYxk9fbPt/nkj2oBG4emQDwc9CQD7c9+4xz0oAwFyAD6DGDwc4B6445+nSgAAypGOMEEAHH4/55BFLyc889eeTnn09s/lmkADAdgBnOBx0xjuO2SfSjkgZBOBnJwAPXjtx9fwoA2fC3irV/BGu22saJfS6df2zHbLGeCD1RlPDKePlYHOAeCAR9+/AL4+6d8ZdGMExisvFFnErX2noSFIPHmxZ5KE9uSp4P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9Tz+Z9Kbwc52+5JxgA9D+OBS84IGSc8HJIJPcduw6e3NBUDIHK8gYx06c9unamgAg5Jwc5ye2Tnkd+fXrikAG3jjoMAk8A/ywaANxzgDODwOMelKCG64J6jcDk9Tx6+nXrVDPT/2XD/xkL4IIwc3F1kA9P8AQbmv0kFfm5+y8Qf2g/AmARm5ujzjP/HjdenB/wDr1+kY6mvyfiv/AH6K/ur82fuPBP8AyLpf4n+SFooor4w/QQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGjp+NZviT/kXtT/69pP/AEE1pDp+NZ3iNd2gakPW2kH/AI6aqn8a9TGt/Dl6M/KvWh/xOL3dlR58nQnPU9/Tpx3qlndyFIJGcAdOO1XdbI/tm9xkjz2B5z/EcjHT+vWqR6HAx1BAHtX9CU/gj6H8s1v4kvVhnJI69D0OTnPPuKO/pk88EjrjGOv4fj1oYHO0nAzjI9P69eMAfhRnJXOSD0498Y/Dj8CK1MUAGB8xHtnOPUj+h+oowCeM8Y5B5xn6d/8AGgAqoBBAzjpwenOB+P8AgMUhztIzhgDx0GcZ59cYH+c0CHBiCDngckgAd+OfX6f/AKk2kDByR0yRxjrn9APT8aOVGRuAxwepx179epoxjOTgkgE4/wD1DIHX60ABwWJPI688579fX1zQepGTgjGTgZ6/r9M9aQgMpIABI7LnH6DsP1HpTlB7DJ6kgdRk/njNTcBqgYHoccg5GSec/h+mfSgMcAnggHljk/8A6x6f4UYwOSCSMkA8HH5cEHng0pBByMnn0Jz6A5+n6VQCfiTweBwCfpzzk9ewpSDnOcN1BAwM8gds9zwPxoBxjkjnGenYHIz05Of60c5IAJA5IIz78c9O+PwoAQD5SDx9Dnk//qpSMEEZJwSCRyMf/X96QIAf73Xg8j8z34//AFUnPclgBgkHg46/nn68fjUoNwUjAGB1AJyD+RHHP9D9KXAJJzk9OfTHXJ/DmlJPJz6kcYyM/wA8/wCetISQCCMEAjJHB4/yfxqikeofswAD9obwKfW6usdP+fC5/LpX6SDpX5u/svj/AIyF8DDA+W4ujkf9eNyP8/Sv0jr8m4r/AN9j/hX5s/ceCv8AkXS/xP8AJBRRRXxp+gDSeKOtH1OKwdf8a6N4at/Ov71EUnAVMufyGcfU1UYSm+WKuZzqQprmm0l5m9096Bn2rxrxJ+0dp2n3KxaZa/boyMmVn246cAYx365rzfVvj74ru7pntL/7FCTlYlgjIA9MlST2716tHKsTVV7W9Twa+fYOg7X5vQ+rc0ZNfL/hz9o3X9NlYaoY9VjOcBo1jKjtyoGPxBr1PwZ8edA8TLHDfMNEvpGKpFcyAxvzxtk4HpwwBycAGor5biaCbcbpdjTDZ1g8S1FSs/P+rHp9FICCAQcilryz3gooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKr3kC3VpNE33ZEZD9CMVYpMCmnZ3JaurH5OeIbSay1i7S5RonWeRWRuCpDlTx16g9R196oAc44A6EnoTxwR6epPv7V9A/tk+ERoHxCt7i2tXitr6KS78xUO1nLASc4xkE5IzxuB718+5BAGQATz1B74/l+tfvOX4mOLw0Ky6o/mTNMLLBYypQl0YnKnAGCexJz64J7/j9KUEDBGGA43e4Gceh4I49fpmhcgZyB2AU9O2c9fz9+1JuAIHfIOO4A5zj0616J5IFQASclSMgg8YyP/rUpJYgZwSc4HcZ6j1xz+eKNu0YIA9DgjPQgDHGeP8AOKTOSATg/TgH0PfJwOnpU3AFIYE5ViTnb2xkE/lj/wDVSgdM4Yk5OcDOfXv0/wA9KQcHH3j3GMnOPUZ9/wA6AB/DuJ4GSQD3PUZ/Xv161QC84yCSeuMcn3wR/Lnj2xQWBK5Axk5OcnIOMZ+uKCPvDIPAYgc56nnoOPxznpxwFskA4yRjk89fz/nx2oAAcDAORzzyMjGTk5BHPpycUhIOQ2COpBxgf169/elHzAdg3cDHcdvTnj8KAMnlSDnADAg4JyPqe2O/48gAuDnjnPqQT79Mc8D8aCxHBJyOQT1GO5x9PWhQT3JJI6ccHt09iMe9JvO0NkkjJGCcDr07fh7e9SgBgFycZA6DOMjHIzg80vCgYBAHTHUYOScH1Pf3HWj34IHTjngdR07fj2pD94dlyCMZ45GfyHp37VQCgMrcYGOcZ546c9PemqpAIJwAMHAwcknH6e1GACRwASRggD3/AKDrTgSzDnnjPB56nPueB+XpQVY9c/ZOSOX48+FmOCUNyykHv9lmB/ma/RfrX5ffB3xLeeEfiVoep6f5TXEBnKpMpaMlreVcMARn7xPBHI96+pJf2idblsFjKBLorhplG1c5POOcenU9Otfm/EOX1sTjIzhtyr82frPC2bYfBYGVOpvzP8kfRmp69YaPEz3d1HEF5xnJ/Ic15r4l/aF0nTGKafH9uYdWLY578Y/mRXzxrXifU/EN491eXTtNJycEgAjqQBj19PzrL4JJyTnOADk9M4z+Qzx1PfNefh8lpxSdV3fY78VxJVndUFyruegeI/jX4i10XEazmO2m48nA+UcccAfrk+5rhJbyeVVDTOyDkKxwAcA9Pp9BUfrgDPOASCRwR0JHGO9NTGABvI9hn2+mffnPNe/SoU6KtCKR8tWxVbES5qsmwJIIAGMEfLkHB4I/X9fpTsHcR1PTjIPvx9BSHIHOcnkgkEdD1x7/AIYpMkoRyM54yc+v4HPTp69BW+5zXFB6kZyeSMnn8BjnGD+GaRiTkFQQ4IIf5t3OOR0I+velOSzEFuxJGD9eQMj0PX+tB9SMjrwACOen88e1Ik9N+FvxtvvBskWnao0uoaITtBYl5bX02k8sv+yeR2PAU/TOja1ZeIdNt9Q026ju7Odd8c0RyrD+hz69OlfDJDKxPQ55OMfTnP09/Sui8B+P9Y8A6kbnTZQ1tK48+zmY+RMM4JwPuvjgMBnpkMABXz2OyqNa9SlpLt3Prsrz2eFtRxGsO/VH2nRiuW8CfEPS/H+mi4sXMVwgHnWkuBJEfcdx6MOD68EV1Xavi6kJU3ySVmfpNKrCtBTpu6YtFFFQbBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFJQBwXxn+GsfxU8A6ho8bRQaiYy9lcSrlY5QOM8H5T0PXg5xkCvzd8T+G9R8H67eaRqtpLY3tpIIpYJF+62AQQQcMCCCCOCCCDX6vfTivNfjL8ENE+MOkrHd5stWt1P2TUYlBZDg/K4/jTJ5U/gQea+qyTOXl8vZVdab/DzPiOIuH1mkfbUdKiX3n5rEY4IIB9CM/z9ePy7UozkKdxYc8kk9R9Oxzgf146fx98N/EPwv119J8Q2LW8/LQzxEtbzrnBaJyAG7ZBAZcjIHU8wCTuIGT24/POPoOg+tfrVKrCtBTpu6ex+F1qFTDzdOqrSQZCkqCcDPynqfUZ6Y6d+KADnaAxzkdcE9sHA/T+dJ1Bz3PIPTGc4479OaRj8oOMHPHPJ/L8DW5zjgTwRywGck46n6Z5OeKAAARjIwenPQdT+Y69fagAbiQDwSRxz+nPT2ppGBswSSAMAAZx9eR680AP3FuCpBJycjsP8euaQgDJIGCepHOAcYHqBSMxIY9RgYyCOemPbI/n9KCTjBznr82Ac+/60AKSSMZ3DHB4OSMDI7fyxkDvSIADjAzgcAAHt+HT+VKepwSTk4xwSMZPf/8AV+NIVKj5uQOcgEA4Gc56fjmgaAAcjjbnHAAGMd/0/LrQMkAnIPQnHOcjHX3/APrelABOc5JAIOB0/D078e/tSnqQVY5BHPJ7nGev5UFAP4R0JzjIwepGfTv/AJNITwM9c4HIHU/l+uenSlK88DZ2GOMdunuen0/GgZJOe55GMc+voOSPy7UCQHOSBgMcEnGM9ufQ9OPYetIcDIwx69eB+Z6f40gBOcgHOR0wR+nHAP50obAJBHqefX3HX8KBnQ/D/wD5HbShknmUE8gkGJ85/X15wOnT1wA5UDknnPAB4wMg4yPy715B4AUJ410nA6NJwSc/6mTtg+3+eT69tBTAAIweoA5B6+3ABP0968DH/wAVeh9Dl/8ACfr/AJDlIHBwMADocH0Pb27/AMqFztA5z04ORk9CMjI7jv8AzpMEcAjkjgcYPJz07fp9KARkDCggDOBnGTwCB9OnvXlnqXAfNggBlOMkHjHYH8OMf/WyoXDAjnHQ/p14J7Yx60n8QI5Y5AIAJ9QO/AyfypQTkHPIORgkBvTn6Z9+hoAQkIPlyBjGDzgc5+oIOe3fvTjkMckjkdRx268nPI/A5+tJt3EcZ7AjkdwevsaANwwT8uRyT1zx1P5fWncSA85HJOBnJ68+p/D/AOv1o4BIJAUDBwBwPqe3Sk2jJZs5ABPPJ9Ce3pj0zTud2CGOSOM9TnqTzwf5/SkMaCeDkZGCAozk4yOfUHsOacBtyM5xxkcjjnPXoOKQHOSG4A5JOQT17e3fjk045GQe3UkEHgAnHbqfTv70/ILFzSNWv9A1CK/066e0vYifLnQglQeoIPBBwMggg+nSvpH4YfHKw8YNFpmq7NM1knbEpb93dH1Q9m9UPPpkZx8wnO45ABzwAM44A4Azk4/pTSofIPIBPGcEdxjuCCOCORjPpXnYvA0sXH3lZ9z1svzOvl87wd49Ufe3Wg8184/Cv49zaU0WleJ55LmzAVIdQYFpo+373u6/7YyRj5s8kfRFtcRXcEc0MiywyKGSRGBVgeQQR1FfB4nCVcJPlqI/UsDj6OPp89N69V1RYooorjPTCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGgUtQT3UNpHvnmjiUfxOwUfn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HJAY8jGfb064/WgAwuTkDgYJbkjn8eOcnJpSSTk5BYcg5546H1H59eaTIzwAMDgZ9DwB6dvagAEsABtyeMHgd+3HPp6fjQFwJJIAOR65yccke46HPP6UDPbg5OM8n64/D9elOJPJfhjjJyMA9jg/y/GmrjK8qOpBHXqTwfzFABtBYZClegA9OOCQPrke1AO4gHgkjJJA7dM54HXnHNJuA24Iz/tYXPfj8genp68KMhlOOd2AeM9Ccc8Dkk56dck44AFJJXGTk9DnByenr7c9uKUc5IA7dzz1xk/T+YpqklQR90jqMADjnHbr707ALYwAG46HA5z6dvQdfyNAIQ8E5XI7AkZ4/r7ewqSCeW1uY5IpHhmikDo8bFXVgcggg5BHGCOaiJwoIBBwcA8HnjOOmMfrRkbjjoDjGQBxjjPrn+ZzSavoxptO6PfPhj+0GsjR6X4ukS3lPEWq4CRvyAFlH8Dc/eHynvtOM+8Bgygg5FfBPXcpAIJwVJ4IOODkemeO9emfCr4z33gh4dO1Fn1DQM7VXO6W1HYocncn+x2BG04G0/LY/KU06uHXqv8AI+3yrP3Fqji3p0f+f+Z9VUDn6VnaLrlj4j0y31DTrqO8sp13RzRnIYf4g8YPQ5BrRAr5Jpx0Z+gxkppSi7odRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAaBSZ5rzb4rfHXQvhTA6XY+1aiBuS0D7N3AP3iD6jsetfP+uft0Xt3ayx6doq2UzA+XIriUr05O4AH8q9jC5RjMZFTpQ93ufP43PcBgJOFap7y6I+yunfFULrX9OslYz31vGV6gyDNfnve/tUfEK6Zx/bR2SAgq0ak85zwAABj2rzrVPFer6vc+fdX85csSQrFRz1PHHP9DX0VHhStJ/vZpLyPlMRxth4q1Cm2/PQ+/PEf7U3gXQftkK6j9ovbclRBtK729Acf0rxXxJ+3Ff3du8Wl6SLGU9JQ4f6feH64r5WLM7Au5d8A7mOSTnvnJ/PPWkGDx3U5wv8Jxx174xj0yPWvpcPw5gaGslzPzPkcXxbmOI0pyUF5HqGvftG+OvEltNZ3ertJbS5JUoB3OBwBjj+Vee3Gt392XEt7OwfkqZGA565GcD8ufxqko4Xj0wARgD+npnvx+C52gHJI6gEd+p5I9gPy619BSwtGjpTgl8j5etjcRiHerNv5iMN7Z6ljgt1Puf89/pSdVJAzkDIz17857c/y98KTyRnjOB0AzjHvxz+GKQkEkjGScDccEAjgcemB+H156ThQoPTIAIySAM4+h68Z/HNLgjgdeB169cHPuDSZIAIxnkdAPp+h5Pv70hHy4AAGAMq3OfTnrznA9M0FC8HOCACcYxjjAP+f6UdOepAJIBwQR+mc4xSEjudozg5465Jx69c0Bsc9wMncAeuePXH1/WgBxA5xgEdjzgHn+h460EEk4GMdASP8jOPf1poXbhScgHBbGOpx0z7kZ+tKcc5GCRznBOMZ59f/wBVOwugvTknIOc5HOAcn8uKMkEBuCQc7s8c8nrjHb3prYX5c4wSCMcYxzgev+FKxOc4zyRjp/k59fUcUhgT0KkccA9O/X+X5Y44pTkkk8Dk5J7dSD24x+lIyjoTznAJOOR+fTr+BzSFhgg9eu0A5HHQ9umB+dBNgwVzg4wMDg5B4yT0/wA9qCSWB5G0EADIAJOeh9hnpQy5J5G45GQM9iMYHtz/AE5pecYxgc9D3+nY+/SrEAAO7IDEgDOM8fpz/hRwxHvxgg9fT68j8cUHBGQCAeTgnIHTr1FITyQSDxkE+vJOCPqemKBoXqRnJOewx1x0x/LsRScDJ+UYycjt2wOOfTr2pc554BODgnPv0/D/APXRnawyGznAJxnjPr3/AE5FBQsUrRyK6OQ8ZDAg4IYEEEEHIII4IIIwORX1d8BP2wDaC18P+PrktAqlYvEMp+5gjatxxyMHHm+w3dS1fKGBuAIAB456nPGfXt1/xpASpwWwR26DPpn1x+PNeVj8uoZhT5Ky16Nbo9fLM1xOV1faUHp1XRn6329xFdwxzQyJLFIoZJEO5WB5BBHUEd6lH6V+dvwI/aS1r4R3semXRk1fwo8haSxdiZLUHOWt2JAA6Hyz8pOSCpJz97+EPGGj+O9CttY0K+j1DT5xlJY8jB7qwOCrDuCAR3r8izLKq+WztPWPRrb/AIc/dcpzvD5tTvTdpdUbfpWP4o8KaT400a40rWrGK/sJxh4ZQfwIPVWHUEEEHkEVsUY9K8eMnFqUXZo92UYzTjJXTPzy+O37Mms/CSSTVNNaXWvChOBdlQ1xanptnAGCp4/eDA67guQT4wPQ5A6FQex4yAMDP4V+uMsSzIySKGVgQysMgjvXyL+0L+yQIluvEngKzGE3zXWhQrlmJO5mt8n6nyuh6LjhT+kZRxGp2oY169Jf5/5n5Ln3CbhfE4BabuP+X+R8ksSRkqMjGT2wTjAPp/hQ3HUHHfJ5Y8Y5PfFIQULqyhWBIZWUghgeQQQCCO4IBByDTUIBwcdQDkYxyMA8f5zX6CnfVH5c1yuz3HDaW4AGSAeAOBwQOPpz9fwdySSVwM8LznP9D14puc+gOMdcjrjnv0I/Kl7E9TkcEDK8jGPXPH0xTECEBWwcgHnJwM47H1GM0EZIHIOTkcfTOP8AP0pM9COgyQAQQp/z+VKCMY6LnOcnnI/KgBdwLnA4I5xjI7Z4PXpz2H4ZFyMA4IIzz0Iz1x0Ix2+tNJOxgB93JwxwM/zJ7f54cQASCMjGCAOSOcj1/wAmgfmbnw/KjxlpPXbukBB5ODE+ceo59K9eXooJHXoCT05wO/T8vxryP4fqT420wAjO+QZC/wDTJ/14r10EEZABGMhcEcDue445z3r5/H/xV6H0GX/wn6/5Djx1PTqcZzwfxOBjj3+lKASACOeAQMnnpx6dT3PemgYIxkknGQMEgEY/HkDt/SgDttYHGDnJPfjJ7c+45rzbHpoUDJJIUnJ3AZAz2H07c9aCTtJJJOMEc559h6k5zS46ZGM54B4/PjPqfYGjkbeAGAwSCQRjn19z+YzSHYQAcAHGMgED27Dvzg0pYM2eGA44II/McdSR6ZI+lLn58DkHgHcT15JPsceuc0gbOecY5AH0OAP159qAAAEgYBHQrzyB0yOo/wAD2pVzhSRtIGSccc8jk8j1x6ZpMjGTzg4+bgHjGfzPbrz60dFJUYHGTgjBx3zjBzz6YoAQ4II4Uc53AZHbB9cDp17dKc2ctkHBI4bIHQge2Tn9PakUBeFwBkYxwP8ADHJPH680AEEleD1JwPbOe2eDxigEGWXAyQScHnPrkE+/PTqfrShugwehGScA57n9OOvFIc4BBwuRjnGP1+nHfjpSkEAjHAOdoGOSO/8AX64oD0Ex82OvGOOD0OPXGcDjPQe9Ky9ckYPHQAH8emDx7+nFIACTjPA59RnIGPTryPpQQSMEkdc55A9fpnrz69eKADIG7A4JPPJI6D8uAPpjnmjPvznIG7I74B/D07fTFDHcMsRxnO4nn0A9R+XWlxjOSCDkEgE/j37gcHPc+uQLCH0BbOcEDPGT37dxx2H5UrE4znOcgnHOepzj245+tBJzjOSMEEDnPbjtnGB3pFxu4xjpleDzg+men54HHagDpPBPxB1fwFqjXWmyl4JG3XNlKT5MwGQScZ2tgDDAdgCCBivqXwF8RdK+IGmfaLF2iuU4ns5iBLEckZIB5U4OGHB+oIHxspJIIwQT6c9AMHnnOB16fhVvR9bvtAvodQ0+5e1vIgRHMn8OcZGCcEHgEEEHuK8fHZdTxS5o6S/P1PocszirgHyy96Hbt6H3V2pB1ryf4X/HSx8XvHpmr+XputMdkQJxHdnH8BPRuDlCc9wSMkesduK+FrUKmHm4VFZn6dhsVSxdNVKTuh1FFFYnYFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAHjvx8/Z7074x6TJc20o03xPBEVtb05Mb+iSqOqn+8PmXqMjKn4F8Y+C9c8A69Po3iDTZNN1CIB9rfMkikY3xOOJF9weCMEAggfq1jFch8SPhZ4d+Kmif2d4gsFuFTLQXK4Wa2cj78bdVP6HoQRxX1OUZ7UwH7qp71P8V6f5HxOecN0szTrUvdqfn6/5n5dHAYEYPPGBj1yRSAHAJ4J46D0z6+nNek/Gj4E678GdSjW+3X+izsEttZiTakjk/ccZ/dv3APDc7TwQPOMckEAHAOMYwfpwcYHv1r9YoYiliqaq0neLPxHE4Wtg6ro142a/rQOuRgkkEgY4bk84/z+NKQT8ucgZA5z1xjB/wA/hxTQcrkA5xnIzjjt0x7Z9c9aXhTgnjgdMk+gHr1/T067nKgAyRnqOcdR17fnSZ5JA5x1bAz+Pr7HsPbNKRhCc7Rk849iCAMfy5pVJyRhuuTk89e36HPv7CgY0qQeRjnBB6gHnr7cfjmlJPfAAJyCTjJx+hOf/wBVDAEHHPHOTkDI5+nUZye1J3yBg9QQMHGME+3YZ6YoF5ABuyMDnjAJ6+mR0wP1oJDDJIHA5xzjvyePw/xNGSAQR948j1+n6A9enfupwCQc5OccYGOBg0CQhwCTnGCSeORn+ucdaAAQFwDjptGeRkfXH5e1L1OGPPcsecHjv16enNIoyGJA5yTwOc9+ckcj/wDXVlAfvHOBzk49MdsdqVRhCM8EHIGcck9MHHv60HOQACOeMnGevsPT17dBjNKASAMMcZ6kAj29sn8agmwhIGcnLZyPXoBgd+38vSkOD3U9snofw/Lp60pHc4POcjPXjGP8DS88cZPfjA6/l/hVhYAQecEE9DkDsf5elNOS2Tk4IwSAOv0/z+tKc4wSw4BDAdOePb39+aQ4yQeADjGMY/L3wMdOh+k+ZQcY9MD7rAHHBx2/nQMBsfcPAwQAePTP+fxpSQpHCjnkEEkHHT64/rQOOMZPOdpJ9+QOuf5mqATJPPQ4PJ55+vpz+lKSCSSMAnA7dufy47/nR0UZOSMeoPHBxx6Y7YpGOFyQCcZIPOB1Bz/+r+lAADxzkjAzzkYPtgH0/GlBxgk4IPOAPUg/y6e3PpQQC2QcgNgk+mTz79j/AI0AngZYHHYY9T3+nXP6UAIAFyBgFST0yc/j78ilIC5+bA5G7jIGPf8ALrRkbiTjOCAfxzk9/wD9YoUgtgc+nr39Oe5/XioJsDNndk5zzlic49fXPXHfmuy+GXxX8QfCnXX1DQrsRCZlW6tZwWhuEU9HXjBGThgAw55wSDxx7gEkdDyM49R+FICASRyuc4659vzx0596yrUaeIg6dVJp9zow+Iq4WoqtGXLJH6afCT4xaJ8XNEW809ja3yr/AKRp8zAyRHpkEfeQnow698Hgd/8AhX5R+GPFmq+DNWg1LRruSxvrYkxTIfu56jBGCD0IIIIOCDX2/wDAn9qnSPiS0Gia60Wj+JWYRwh2CxX3Gcxn+F+uUPPdSwzj8qzbIKmDbrUFzQ/FH7XkfE9LHpUMS+Wp+DPf6TFAOelLXyJ94eD/AB5/Zc0j4rPJrOktFovijHzzhMQ3uBhVmAHUYAEgG4AAHcAAPhXxP4S1jwVq82la3Yy6fqNuP3sEuDgdiCOGUkHDAkHHXsP1grg/iz8HdA+L+g/YdWhMV1FlrXUYABNbv7E9VPQqeCPcAj63KM/qYJqlX96n+KPhM84Zo5gnWw/u1PwZ+Y/QYJwMepyDyOnUHjr9KUEKCrHOSDnI6emc/wCencV2/wAWPg74h+EOvPY6vb+ZaTMxtNSt1YwXCZyMEg7XxwUY9ehYEE8OATnHzHkgjgnt361+q0K9PEQVSk7xZ+J4jDVcLUdKtHlkgz1ySDjBweTjkYP49Pr9aXAyRnPB4yD6HH50cgDsMk8HnsT/AE+mKGB6EZzwRgnPBx9OK3uc9gJAyAVyOPUDjPY9P/r0cEYBznk7s5wT1wOc/SlJ6knkHhsEjPAI7k5J9aAAzEcAEEH24H+OOtUFjd8Bf8jppQOBhpDwCMfuXyc/5/w9fB4BHBHHJI5PI5HY4H/1+leQeAT/AMVppBwAC0p+YHtC2eccZxXrw6gEZJGByex6f4/5NeBj/wCKvQ+gy/8AhP1/yFYEs5xkcEEnORgdfr78cfmuA7YzkZyGAzxkj/D86DyOQAMgk4PHGM+3Q8Dp+tLkMPmwRz97n2Az0AxjmvLPUsBzgjGMDBBGe3fr68fzNB+U84GAPbJ5IBH+T/KkxwSAc8ggHnOPX+p96U8nGccjBDZwT0xjqOOnr+NAXAAjIxlycYxyTjA68cYwc8Y/Cg5cEgFhjHXOMH0Oe/BFJ1HYdcfNyD+PTufbFKRlhkYzkkE8nrxj8enHf60AJwrHJAO4ZI9PXn6459O3FCnBUngqRjnOMHt680uSCDncMZOSCT1xxjvketAwzHawJ4HXkckjPqOf/wBdABggDjPGMt7E47dcH07UpB3ElWxuweD3Bx6+mPcZ4BpEIOSpzkgE8jgjr7cH9DQBjB6ntnn/APV+Z60B6h1ByBnPOQCMDH8/6e1KeoGRkEEZ6cDPA68AA/n9KTIcDkHkgEjHoB/I/iPwoP1AGDx0ABGMenf68+tAACcAYySCCRyPoT29/wD9VJ6kBSByMng8j8R0pVUgKDwccYIznpnsM4x+QpQcYPIOBxnngDHXr069semaPQEGDkqBzyTjHT39+2eeSO3UJJUHAJBONo6nPIP8s+uKTgbQMgcY4BGRnkD6d/rQh3HgggYIAzg59Bzn0FAAcdjjggNjOcnvnGe38qEbJ645Bxxn1xwDjrjt/OgDBAAwSB25J7Zx09KC24fwspAJDYIwOn9fy+lABt+UA8HGSQM9zj8cjp+H0VSSQQHBJzjHA7jnnOc96Q8nrzgnJGQD1H14xz70m/OeAeTyTnHJz9T/AFFAbCvzhcFk9yR0I5z2x145GB3r2j4VfHybSzHpPied7myAVINSclpY+2Je7Dp8/UfxZ5avGDlM55I5OR746Y5/TJP5r3JBOAOSOuM/5/yK5cThqeKhyVF6PqjuweMrYKp7Sk/VH3bb3EV1CksMiyxOAyuhBDA9CDUv0r5D+HHxc1b4fTRwMG1DRSS0lkWGVJJJaJicA9flOFPPQkmvqPwt4s0zxlpaX+lXS3EJO1l6PE/GVZTyGGRwexB6EGvgsZgKuDlrrF7M/UsuzWjmEbLSXY26KKK849sKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAMzXdB0/xNpNzpmq2cOoafcrsltrhA6OvuD/njNfEHx5/ZM1H4etd+IPCpn1bwyu+ae1cl7mwTqQMDMsYGeeXUYzuGWH3jzSYBBFerl+Z18uqc1J6dV0Z4eaZRhs1pclZa9H1R+RZQ7skKw4OSOeg7+p7H0PFBBQAdduQCOvsP5fn16V9qftB/slR+JXn8ReBoIbTV2JkutK3COK7OPvRk/LHIffCscE7Tkn4wns5rK6ntrm2ktbmBjFLBcRmOSJs4KMpAKkHOQR/jX69l2Z0Mxp89N2l1XVH4VmuUYnKavJVV49JdGM7HAH0Xj1xz+H6g/VpHJGTycc9ByDwPb+dGM44J6H17fypcDJycgnJIP4njPTBr1TwhAAGOATznGe3X8eOO3b1oI55HseMDv8AnyD+tAYnIJIJGCSefft/n3p27kHHJxnGCfzx+Q6UCsNHLZIPGeCfTjHGOevfj0NCqFxwOmMnkDkcc8kg4/OlVV4AG0cAbRg9T/n+lAxnrgAjAxwAenA6DsfrVlCHgYwR1Gc5/DPqKXnnAyMcgk56k/5/D8BgBknAJ6hucjHJHt/j+ZjkckkclSRgYHBz754Ppj2oAU5zlicdOeRgcZ546/y6UgX1PIBPzDB6ZH16/wAqBgg5J68tjkHHU+3J9v6g6gEAdBk+3PXjGCRkfzoAUkYPTn0Hr6ehyP8AOKDnPJIxjpgE+4/L8fpQRjJ+bJAOMYP4/mRRkDcMggcDByOT09Oozn+tQT5gMjAOAw4JA4z7DHUcUOASflwTgAEc/Tnn9PzpCM5BGcf3Rjt04/8Ar5+tKWOSSSOSTwCeox/Wn6Bp1EJGTjHIIOTj3/D8u9IxxuGSDgHGORk+/sOlKy9cgdMYPIPFIcckE7Tg57Yx0z0GPf8AnQhDiDuI5AJwOOgHOPQZ/mKbuzg5AySDnjnAPIPQ4z+FKxySce5GcjnPPt3/ADpSCTgAEkkZAOckcfyz+HvVAJ0IPoec8Y69x3/+t6UikAcE8E8qOB17eg/w9OTcevTg/Mcg8ZI69RzijHJ3EZBxknOPTp/nigBR0OcFc9WAwR1H1z6emKQEgkg5PU4JIIz17cdz9KXhX6YHcg8jnpn0/lijIJI4B7L37jGOnQigewijaQM4GQMnA6np/n1oBwRznPBwQDnBOPbGP596OgzkAZyT07AZB6d6UDdnjnv1B79x6Dp60BYTBJ4AzgAYA9MYz+VOVjGAwzgYI2kg/UEdCD3HIpAOmCCTwcA5PUZHtjApCBkjBwQQCoxx7AcnjPXr+VK19xxbi7o+rfgB+1s+nCDQfG93Jc2SqiW+sSkvKh5GJscuvT58ZBPzZzkfYNrdRX1vFcW8qTwSqHSWNgyupGQQRwQRg5r8kixVg4LKQcgjOVPGOffnmvXfgn+0hr/wgnhsZd+r+F8t5ullh5kRJBLQsThTySUJ2sSfukk18Bm/Diq3r4NWe7j/AJH6dkXFbo2w2Od49Jf5n6LUcVzfgP4gaD8StBj1fw/qEd/aMSj7Th4XABMci9VcZGQeeQehBrpOnvX5tOEoScZKzR+twqRqxU4O6fUyvE3hnS/GGiXeka1Yxahp10hjlgmGVYH07gjqCMEHBGCBXwx8e/2XtS+Gk0us6GJdV8NsSWcLmWyGM4kwOV4/1n4MB1P350AprxrKpVgGU5BB6GvVy7M6+XVOam7x6rueLmuT4fNaXLVVpdGfkeUMZAdWAGDlh1HXjuPwpCpHBUHt1PPPTHpnjgfrxX2F8ff2Q0vxca/4Et1juNwebRAQkbDOWaA8bTyfkJ2kZ24OAfkS60+4064e2uYZIJ43aJ45IyrKwOCpBAIIOQcjIPav1zL8yoZhT5qT16rqj8LzTKMTldXkrLTo+jIAAe5JyMnHPvgngc9uc4pByoIGQTnI5BHb9D/9anA7mzhcnkADI6HGT0HpQOh6EE88cHHbPY8D869a54iN3wAoj8aaX7NICx46RP8Ap2r2Ec+hOQe4J9Mkdf05+teO+AW/4rLTME8tLknpzE5/oO1ewE4bDEA8AgHJBznkZz79sZBrwsf/ABV6H0GX6Un6/wCQoxwMAcjIHXOOoGfTHHNLywO45z1AJAxgDHHbrzkUgPGTgBcEYJ9SOR165P0NL5ZAxtBdcdecjt7d/oOa8s9NCOAxOdpOAACcdyPXt6fj9FLMxJIOck8g9iBnGP5cnmj7oOBwDjGeM9Me/J/M0MAckjAyQcjGMHOcZ+p57dO1ABjPBO4DrxjB7/U8UbeRjkEYAAwccccZ4x/KkYkfN14OM8ngnt+v50qYOcAEDIIHIHJzxnrigLAFGMAEAg5wTjBHoOv4ijIcHAzxgcAgH05/A59zntRzg5yc4JGc8YwD/Pjv7UNjPOcDJG4knHI/Hkcex96AsAIZt2SSeNwJOcHv9ORQAMAAH8enYZ/XgdeOelOBIJbnAOTjuSScenXNIw/E8njABwcc9fQ9O3tQAF8ZO3jG7k8cYOOvH4/rSEENySBkcEjkjoMe3P40KCGIGATkcjjGQccZ4PA+gP4ikMQV9cAr1AyeBjg57/h6Cj0ABjJOc8855GTjr+nt196GBxyMgAgZPAPXsRx2x7E5pcE4GSc5xxz+g4yeP5UHPI5HGemOM4PHPHT88UAJjHfBJwc+vv8Al79KCS2ABznIwcnrzgenTn+VG4DJzgewI4z2/Ht6euM0YwNpHJ4IwcMfqeozjHc/iKAF6kg4JzjgZGcdMjoP8/VFbOc4AGG5B6nIxg+wH1+goBAXBJJJweBknp0/DPNKxxgE4yeG6AHkcE47kD8aAEZcHkjIJJGcgE9yOvpRknIyRgAAk4x9PTAz9cjsaQtgH7oI446g9QDz9SO5yadk5yASOccAnGeOegH09PSgBMlSSeTzjAySO3b6j0o4OSCCS2ACc5z9Tzx/I0KMDA7ZIz1yQf6Y54PJNAJKg8HByBnGOxPbv+YHagBMZBJXIPIOOScjr+vIPfFbHhTxfqfg3VU1DTbhoZs4dCCUmUH7rA4yCDkdCOxFY4JwQNpI5OQRjHGD3Oc/560jdWAGRnBUck9sfp+lROEakXGaun0NKdSdKSnB2aPr34cfFbTPiBaiJXS01aNA09kzcj1ZDxuX3HTIyBkZ7nvXwZb3M1ndQ3EE8kM8Lh45YWKMjAnGCDkdPx6EEEivo/4I/Gi68aX8nh7WY0OsQ27XKXUK7VniVlQll/hcF1zjg5JGOlfF5hlbw6dWlrH8j9FynPFiWqFde90fc9mooor54+yCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBuOK8h+N/wCznoPxgtmvFCaT4ljULFqkUYJkUHiOUfxp+TL2I5B9eNLW9DEVMNUVSlK0kcmJw1HF0nSrRvFn5Y+P/h3rnw28QS6VrlkbedSWXadySx5wJFYcFT+BB4IBBA5gAdQ24cYIPU8Dn3wf0r9SfiN8NND+KPh+bSdbty6MrCG5hIWa3YjG+NsHBHHByDjBBHFfn98Y/gN4i+D2pYvkF7o9xKY7PVbZTtkOCdrrz5b4BO3JB6qeCB+rZRntPHJUq1oz/B+h+KZ7w3Vy1utQTlT/ABXqeb5IPBxgYOSevvg9Mn9ePWgcZwAR1wSSO4Bx9aUnABzzgkKRgE9uO3A5/DNKoG7b1we3Jxx+vP619Zc+IAcscHnJwSRlvr7cjnjnNIucZPByMhuvJxznHb9BQFzjICn6Hg8Dn26dsE0Ajrg4J4A4OeOCT9MZ9qQrBgDgkdDzg/jn8P6Uu4dAAF4GP1/LJ+nGKAcEjnsDkZOMj86FJI4BPbjnHHB9iMn8x6UAhCuSdxXI6kqeOM8DoelKpwcAYOBx6jg5/P69aaBhS2MHGRt49vYY/oaeQSzbgBnAwTjjH06/4GgNRBkHGcnPPBHHX/69JknOegAIz7Z/Pv8A5xQpGQDgHjAAwccc49Pfig5yAQTnI5Bz19cY5470AhWAJII/2cjIA5/D6jpkY60AYxnIHfA6etIAC2MAnoACQPrj9f8AOaTI2Eg8BcjnAP8An/CmgsLkE9COoPXODwOc8DOf0zQepI5HXJBIx3PP/wCrI+tKx+Y5OME4IJyMZOMce9ByCCQM5BHJ9fbnHT8/c0hgd4K85zxkg4JyRwR34/8Ar+qZIAJ54JwBxwD0zn6fSgLhSNpyvOByMcY6j2/DNLtIJ5Axgk47j8M4/pVgIMbjj0JIwMeoGcfzoDDdkHOO5Pv3I9OtDcgkgkHqMgYGOp5zj/63FBJJYEBjyc49s8Drk+30+kCQi/MOpOCQOcnj0OPX1pTyck5Hqegxnjnp2oySO7HJJIx69fzwaFXGMA9c5Bx+OB1+oHYUB0EyFycgdMkjGTwRnPr7ds0YwQTycg55zxxnOPw6dvajduXJxnsAQcAg+hz1x+lOPAI5C547HPqMdDmrGIFOAFHGMdQR7E+vH54oztXpwMk9u3UY4oXG/oCeD3zjPT+VIuNgwR0IyeMdePYYH0/LgEg2lTk8kHDHBOO+fp9Md6XkE5x6Aduh7j6f4dqTg9gOMgEDGD16dh1x05FGATyASRjPsfw69Ppj8KAR1Pw8+JOu/C3XotV0K9a2cMPOgfLQ3KjPySqCAw54IwwJ4I6H78+DXx60D4wacqWsi2OvQxLLdaVI+XQE43IcDeme46ZAIBIFfmyO2TjGc9v8/wD16taZqt5o2oW1/Y3U1leWziWK4t5CkiMDwQRjvkEHggkEEHFfNZrktHMVzL3Z9+/qfWZLxBXyqXJL3qfbt6H619qK+af2ff2sYfGUlp4e8ZNFY68ykQ6ig8u2uyDwrDP7uQjt91iDggkLX0twRmvyXF4OtgqjpVlZn7jgcfQzCkq2HldfkHWvHfjt+ztpPxc0+e9tli0/xOkJWC7bPlykDhZQO2QBuA3AeoG0+xfpRjJrKhiKuGqKrSdmjbE4WjjKTo143TPyo8YeDNX8CavPpGtafLYXsONySD764OHVhw65BwynsRwcgYe3gggjAzyDz3zxx36V+oXxK+Ffh/4qaOthrlmJXiy1tdpxNbuRgsjduvIOQeMg4r4F+M/wL1z4OamVvVN5o8zBYNUjXbHKTn5SOdr4BO0k5wcE44/WMoz2ljkqVX3an4P0PxLPOG62Wt1qN5U/y9TlfAII8a6WQSD5kgBwDj90/H+f5V6+p7kkgAAk5wMj2HGAD6D16V4/4C/5HTSyASd0yg+/lPj8uPavYAMnB47gEA7R3x+ecc9cV2Y/+IvQ8jL1+6fr/kKFJViCSVzkkHIPbrx36dP5UowGwAAMkhc8A8Z7e/p/I0idBtAB6AA+ozjA/Hp3+tC5AUAkDnAxjB4JOPX3z2rzD1BVBQjAAweTnOOpBPfPUd80hwBgDIGACxI9ucDuCOTnn8qXgcZyNwIPYkD6dOMfX8qaCAoO8nIA64HUY9SP06+1ADsjJwMDtg4PfqB9P09qUZZsHkZIxyCBxn16YHvSZOQORngE4IPIHHI/LPXFIMkYGAcAZHr64ycD6+tACgkYOclQDkDIBwenX/J60ABGOOACDtB68ccfj396AN2MDBJ5yMYOMjjH/wBc9sUEFDzhcHk5wAP/AK3X0xn3oACAp4OAACWPQjP5enJ64FKSQ2cEkkcMMHGRzjr1P5ntnFNOACx6cEbSM9cfTqR+P1xS7SMjIzkEkKQOnB46c/1+tAAABnnJxzxxjIPryM5oCksVILHGCMYJ5wfzHH4GgnIOGOCccjHJHGQc9euc0g5zzgZAPGAOOOhHp+tABwevygcEk4I5GOnr0Of07rxgYA5wRg5IPvnp1/T6UKSCNoYHAG3jI64HT6fn+FDDBIycHHzAbunBP1GPUdKABvm4wxJ4wSOh9/zP4e1DchjwAeeg47g9/U9B35pTycE4OMYZuhweQfbI7d+DSDoDjGCWxkEHnn3zn/8AX2oAGJJIIBOSSG6EY6Z/Dv6GkACnAx1ydvc8H25z2/yEAKjbgg8HOQM44/HHOPwpJ5Y7VSZXWBTkhpiFAOcYySPyoDceoPA68dc4HUDHqOB+vpzSZyM4BAwRwcHIB4647Y69+1amjeE9e8SPGdJ0TUL9XBZJY4GSJs4/5aSbU/Xt713mi/s4eLtTKPey6do0bH5jI7XMq/8AAFCrn/gZrkqYuhR+OaXkd1HA4nEW9nTb+X67HmBXDHOD65HB9OP8jj0NR3FxHbAmaWOEesrBQSBx15J596+jdF/Zd0W32Pq+rahqsg+/HGwtoWPsEG8f99nrXoHh74V+EvCrJJpmg2UE6ncLhohJLn18xst+teVVzrDw+BOX9f10Pdo8N4upb2jUV9/9fefIujeGdZ8ROo0rRr/UN/CyxW7CLIP/AD0bCjOO7V3ejfs5+MdVEbXf2DRozjP2iUzyr6nYmF/8f7V9UhQo4AH0pe3pXk1c7ry/hxUfxPeocM4eGtWbl+C/z/E8S0P9lzR7do5dZ1i/1Rx1jgItYj7YX5x/33XpfhT4feHfBCONE0i109pAA80afvJAOgZz8zfiTXRUDmvIq4uvXuqk20fQYfL8LhbOlTSa69fvHUUUVyHpBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAJ3qhrGj2evadcWGoW0V3Z3CGOWCZdyup6gg1fIzRQm0009SJRUk4yV0z4Y/aB/ZWuvAwudf8AC0Ml94eQBpLRAZJrMZO5j1LxgH7wyyjOcgFq+c2Uodh5xwRnAI9QemPp2r9csbhgjivln9oD9km21aG61/wPara3675rjRYQqx3LE53RZICPnOV4Vs9jyf0LJ+IrWw+MfpL/AD/zPyzPuFb3xOAXm4/5f5HxmTzyeSOQDz74546//WpoJJAGCffOMfhzgk/z61Jc28tlcz29xE9vcQO0UsUilHjdThlZSMhgeCCMgio8k+hJbsAM5PP+f5dK/Rk1JXR+UyjKLakrNdBQeg5GDnsTnn2IHvz685pVwzDuOAOcgZx0A5GD39aaWyThsjnvyeo9/wD9ee9K3zckEc8jOT7j8MenerJuCk7VPXoT74/wPPHTNDZBOTvOCAeuD9PbPek3HIJKk5yQSeMdDjqe3HoPpQCAOoAOB1zjqOfyqBjioJJAJGeCCePx/DHbrRjvxkjgcgDHT1PXP6UnVhk/xY4JIzgde3cfh+NCkhRj0xwCTyMgdv0psBF5GAOOn3uM+vTvinc7gSGyeMZ5/If54NG4gnngf3uT/wDX/wDrUjYAwDx2Bznj1xzxmkJhgg4YZPQjg46evQ//AFqOhABIGeCOQDgHn8B29qXpnGSM4DYwSBgY9+OPekADYGAQQPmwe2f5E9Ov4UBYCuWwQCSCD3PTv6+uO/rQHwwIOSOOoHI7Hn/OaQklQSMcA4PIHXgn6ZHvkfg5c8HJxnOcnH44HvTsJAqsrgZGemT0JxwOOOhH5e9IPQEkdASQCBnPb69+f5U0/L8oAwMYAz1z144/z04oAOcAcZyMjnGRjj+pxVDtYU4fJOAex5yOMDrz0z+QpwznJyBk5KnJ69vU9/amnjjJI6gkc/j6f1/OgHB6cA8nocggZHrjj/IqBhgjGORyD0weR6+hHt70AEkgDcVOenUHHOT/AF55/GgAEgDPJ4xgA8YOB1x+ooJDA5BPHIIz05HHB4/z3qwDAxtySM5464znOMY6/wCP0AwKnOM4IIBz6HIxjjg9u35h3LvAOCMk4H+eOPxwfelUgPgbuSeR2x3yc8jjrmgVgcgMeQSDnHrjpj1wMc/p1NDA8g5bJxu69jz+tG45GAQccBjnsen55pMg4OcHGDgDAHUnn2zQMG56gg8Hpnggc4POOelITggEgHB6noccAe/680vOOSTnqARkDn16jnsaMEAkjABGRgngY5/H/GgAyQ20D7wwQDgYzyPxyP0r6X+AX7Wl/wCHJbXQPFfmajozOI4b7hprJcYAbvIgI/3gCcbgAB80Y2tgDBweM84747en5fWl3FeQct/eHBJBz7AexH9a83G4Ghjqbp1l6Pqj1MuzLEZbWVShL1XRn6z6XqtnrdhBe2FxHd2k6h45oWDI4PcEcGrn8q/Oz4NftH658K7gW5B1LRXYb7GRgoGTgsGIJVsd+hxyDwR91fD/AOJOg/E7RhqWhXi3MakLNC42ywP/AHXU8g9eeh6gkc1+RZllNfLpXkrw6P8AzP3TKM8w2awXK7T6r/I6k8VleJPDemeLtFu9I1mxh1HTrpNk1tOgZGHBHB7ggEHqCARgitQ8n29KXGPrXhxbi007M+ilFTTjJXTPiL4g/staj8L/ABfa67oLy6p4TRpZJd53XFiDGwwwAy6DIw45AHzdNxxACFQZVTgDpgZIyD9cfgePWvvbAbgjNeD/ABa+BEk5l1nwtApkLeZPpmcbuOWizwD/ALBwD2IPX7PB53KraninqtFL/M/PMy4djRUq2CWj1a/y/wAjwM4KggKBnPbgHPr2IJ6+uKMEcDOQe5Geg6jJxnjBPqeOlBDplXDoykqyOpRkI42kHBBB4wQCO+KVhwcnvn5hkHtnj05/Mc19KfF7CA7MkZPv3PPTPqT9eOlOxhgeM9yO/T9P6nFISSxIPPUjPYE9x27/AJe1KMFj6EjBPtnpnk4Izj0H5AgBLMcZJwcjIPOB19wO/bP5jY5HBABJDAZwBznGcjPH50DnB6HGeowDg9+mCM+tA4dSTyOMFee/OPxz9PrQAozu5HPBLAgZPHX8f5D0pM7RgHGQMLk444HHXGOf/wBdByF3MTnaRnOO/buAc0EZO1gCM4wTg+w68Y4I/wA5AFJ+bIOcgkbuvUHg+gx+nbuhJDA7eAeCRx0zyen5dfTNDMcE8KM5zu75/DHUGo5Z0tgGlkEOSQA7AA+3Jyc5J9aAuSHLADLHJwNxyWOByQOmB/LrRks4GcEjox44/wD1H/8AVWnonhHxB4kVBpWh6hqEbqSkyQGKJvQ+ZIVQjg9Ca9A0b9m/xbqe1r+507RomyfmLXUozjqq7FB47ORXLVxdCj/Emkzuo4HFYj+HTbv/AFvseVgZC4BGOR6nofwAwceuee1MmmjtgDLJHBHyN0jBVwcnnJx/+se9fSOi/sw6HbbH1bVNQ1Vxy0aMLaJj9EG8f99mu/8AD/ww8K+FZI5NL0Gxtp0GBc+SGm/GRssfxNeRUzqhC6gnJ/ce7Q4bxdSzqNRX3/1958iaH4V1/wASvH/ZWh6hfK52+YkBSLj/AKaPtTA45BrvtC/Zv8W6oFa/m0/RImHzKztcSj/gC7VHH+2fwr6kCBeigCl7V5VXO68tKaUfx/r7j36HDOGhZ1pOX4L/AD/E8X0X9l/w/amN9W1LUdVYffiST7NCx+kYD/gXNegeHfhl4U8KOsmlaBYWc69LhYFaY/WQgsfxNdT2oryKuLr1vjm2e/Qy/CYe3s6aX5/eIqBegAp1FFch6NrBRRRQMKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAPEvjv+zLovxchl1OyKaL4sVQV1CNPkutowsdwoHzLjADD5lwMEgbT8JeL/AAPrvgHXZdJ1+wl0++iUSPGfmVlOQGRwMMpIIDDjIIIBGK/Vj0zXH/Ev4WaD8VtAbS9cti4UloLqI7Zrd/7yN26DIOQcYINfVZTntXANUqvvU/y9P8j4jO+GqOZJ1qPu1fwfr/mfl3yAOgIIPA46envjt6gUmBjGQBnkkcjvz/PsfyrvvjB8E/EXwd1poNVh+0aZPIyWWr26HyJhnIVh/wAs5CM/ISc4O0sAccCxAIIOAOc8DoB39M56H1r9XoYiliaaq0ndM/EcVha2DqulWjyyQ4kknsOhLEDBIORz7c8ev1pGAIPAAPQEAYHAGAPX/PSgDBIOQe4ABx/Q0DC4z8oHXn04x0x2659PXjo0Occ2Q5AIyOh64BHY9OoP0+tJuOMgkgAkNjr+nXrSDjGOpI6A4znv/njHOM0MMkjGRjBBA4Gcdue/r09KQrjsEOQCcZ4yMc56ZzxyD196RjgA9sDknI559PoPyoJydxIUnoSQcHP17A5/OkXHGAenAGc+xI/PPuAfegYEE5zgnqQD/L8P5CnYBYjapOfYH647DBPp1NNAJUgckgYI6Hv1607lyDjq3AA4Gef6/wAqdwGnPIxzjHP6c/XGaU8HK8g8EMMZ/LtyPzpOBgjGDnpgdse3t3HWnbRv6dSAMjJ6f09PpSAaepJHzZwRjg4GQBj69BQAAMDOBk9B0z14x70L8mOpAABJY55wPr+HvQOMADdgkHIwehz0+mcU0LcOGJxtAxySCD/h7/5zSjJyQcjjBUADrj07+3r70zgkEgnIII4BHoP06/8A66eTk8nnnPJBGASQP8jtj0qhiKdpJ+7k5HYA9/8ADp196AAwA4AII4PBxjIGP6e9IQBnoWJwAcD69+p4pRz0+Y5POCeOD09eP8mgVhGBYkEYAOOBj6Y9eenuPrSg7c9vU9R19Px6e1APy5wp24wTzgDPc9Rk9KM5Uggknqe/59eg79qBhnAx0HPB4z+PTkH+VByCOuM9cAj2OOp//X+CrgkheASBwfXPvye/4d6aMBTkccgliOT7VKAccMw6Y6EdM9wP8/8A1qQDb1GDjJGcHr+eP8KXLcjBBzkEDv155GOe/sPShgB9c4BJA+mfXnP+HejyATJBwOvJG059T6+x59aFwpOORjOc5IH6e3XuBmlVGlcBATuzwoyev5Dj1qG61G104kXd3BbEHLK8nzYz0C9c4z29KLjUbuyJipZhhSWPc89e/Pc/4Vv+CvHut/D7WYtY0C/ewvkQoCBuRlJB2OpOGUkDIPQjIIOCOCuvHOkwjbCs923AJjTYvXgbmI+vTpj8Me7+IN7IQLW0t7YEfecmVs/jgDr6Gs6lKNWLhNJp9GdlFVqM1Uptxa6n6n/A79oDSvi5p628oTTvEEIxNaE/JKQMl4ieSMclT8y8g5GGPrXINfiXY+PPEOnapaahBq95Fc2sglgMcpjWNxnayquACCeDivvz9lH9tOH4lXNp4O8bSxWfimQBLPUflSLUWwcoQMBJcAkDADDpg8V+X5zw/PCXr4dXh1XVf8A/Zsj4gWLSoYp2n36P/gn11RRRXxR90edfEb4MaR49L3iH+y9ZIAF9Cmd4HQSLwGGOM8MOxFfOPjD4b+IvA0r/ANp6e7WeT/p1ohmgIB6sQMx9ejADPQnrX2jmmsobqAfqK9fCZnWwto7x7M+dx+SYfGtzXuy7o+CopFuI/MiIkjJyDG25cDr0OKfnDYwcjjk5PfjkdemOD1Ga+xNe+EXg7xJNJPf+HbGS6lO57mKIRTMfUyJhj+dY3/DO/gQ4/wCJXd4HQDVLsf8AtWvejnlBr34tPy/4c+Vnwzik/clFr5/5M+VNpGcBiBwMAgg8HgdOo/D+UJu4hOIRIrytkLFGSzntwoySePrzX11Z/ATwFZSq48OW9wy8g3jyXAH4SM1dbo/hnSfD0Jh0vTLPToj/AAWsCRD8lAqJ57SXwQb9dP8AM0p8MV2/3tRL01/yPjvSvh14t1wldP8ADWouDgmS5hFovb/nqVJ+oBrudG/Zo8U6g4Oo3+maTEV6J5l1ID6EfIo9+TX08B6UucV5tTOsRP4Eons0eGcLT1qScvw/LX8TxnQ/2YPDtnsfVb/UNYkH3k837PETnPCxgMB04LHpXf8Ah/4a+FvCjrJpWhWNpOox56wqZT9XILH8TXTk0ntXlVMXXrfxJtnvUcvwmHt7Oml59fvFCgdABS0UVyHoWsFFFFAwooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigDL8Q+HdN8WaLeaTq9nFqGnXaGKe2nXcrr/nBBHIIBHSviP4/fsq3/AIBe513wws2peHSTJJD96XT1CnJbrvQYzu6qOucbj93dKCMjBHFerl+ZV8uqc1J6dV0Z4WaZRhs2pclZa9H1R+RYJKjgkFeBuzkcEY9QTj/JoDBAMY2jkFeMDGeMev8ASvsT9oD9kNNSafxF4Ct0jvCd1xoYISKQE/M8BPCNgklD8pwMbSPm+QbqzmsbmS2uUeKWF2ikSRSjKynBBB5BBGCDyD1r9ey/MqGY0+em9Vuux+E5plOIyqryVlp0fRkPC8Ak8gYHfnpn068e/ajBBAzyOMk+2Onbn/PNGSckjBxggcg5yeD/AI560csx43cnIJH09+2fy4r1rHiIUnHHOQMDHJ+n5E9fSgt8wOc89AcjuMe3X9aapGMgDB456f8A6+KUZJBIJI74yTwTwfoO/wDTlAgGB90EEHHTJ7cfoMUDCEYAAIOcEfyx3/I4o44YHIGTuBIPX6Y9T+VBBXIKZ5OOg6En9evtgfSrGLxkAjHcjIwT6HA4/rzSbQ3J9sgjI69vfGPz5pxGTgEEZwBtycfQ9vz6Gm9unoBkY5z3/H0qAADLDgjOOWxjrnrnA/8ArH8DkADJVhxgYJ+nXrzQQuTgjH+z05ye3U8Zz3wPwQZGACcDrtGMf0P/ANcUAKrDBwTgDjnkjHBHr/k0h+QAEkjPOR1GfXpjI70BjgEnOcHPXJz9fp+VG4Egg8Y65AIGcZz9MfmKaC2goJb68jsSCOwH5f1pACOhGAeSCBznjPtz17UqoZHKqC3qFJYAYxwOvY9PT8q93f2mnKTdXUFs3GVkkAYc84AOSceo9KEUotuy1JxzyAQAQCcZIzn/AD7Uh4UgcgDgkE/jx/nqc1z934502FcxCe6YDgomxfQZLc459D1rLufH12+fs1nBbf7UhaVh6eg9D0I/OnZmqozfSx2xyZCAGYnnA5J454+hA9OM1Bd6nZ6eCbq8gtzjO13G7GMjC9T27d+O9ecXevanfqVnv52QnmNX2L+S4HrzWcUCk7cA+oH9aaj3No0F1Z39z4402D/UpPeMB/AnlqTxxljngHsO9ZFz8QLyUYtraC1AHDOTKw4x34/TrzXMFd31Poc/56ikB+YjH1x2/wAM0+WxtGnBdC/ea7qV+CLi/nZSMFA+xcEdMLgY61QRFHIAGe+MdvWlwQcdOuO3+c0cAHIzjqCP0/XpVWNfJAOSM4J9T649OaQqAOgPuPX6/pTumOM+/wCPY/lQD0PGevNUK43ueScc5Hf/ADmpI3aCeGaN2jkhdZY5ImKtG6kFXUjkMCAQRyCKZzx2wSOKRhkkY69s98cmoaTVmXFuLTi7NH6u/sefHWX44fCiCfV7mGXxXpEn2HVRGFUysBmO42A/KJEwTwBvEgAAXFe79K/L3/gn341m8NftEw6MZJBa+I9MntHhVsK0sI8+JyO5VFuFH/XQ1+oNfh+d4JYHGyhFe69V6M/dslxjxuChUlutH8h1FFFeEe6FFFFABRSDmq15qVrYAfabqG3B6GWQLn8zTSb0RLaW5aoqlaavZX7Fbe8t7hhyRFKrH9DVwmhprRgmnsLRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGnmvFPj9+zZpnxdtJdS09otM8UxxFYblwfJuCB8qTAAnHAG8Aso/vAba9ro610YfEVcLUVWk7NHHisLRxlJ0a8bpn5R+LPB+ueBNdn0XXtOm0vUI1BMcoysino8bj5ZFOCNy8A5BwQQMc46HIKnA4+6O/b+f8uK/U3x/8N/DvxN0b+zPEWmQ6hbq2+J2+WSB+zxuMMrdsgjIyDkEivkH4h/sO+J9AkkufB+ow+JbEAkWWoSLb3i8jCh8eW56kk+XwMc1+n5dxJQrpQxL5Jfg/wDL5n45m3CWJwsnUwi54duv/B+R84A5XhSMDA5PTrjPTHP8/egHHTj1JGDz6/pyD3+tbXiPwD4q8GtcDXfDOsaYkDbXnnsZTBnnOJkDRkY6ENiuaOp2IYgXtuCOCTKA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" />
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
									<br />
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
															<xsl:for-each select="n1:Invoice/cbc:IssueTime">
																<xsl:apply-templates select="."/>
															</xsl:for-each>
														</td>
													</tr>
												</xsl:for-each>
												<xsl:if test="//n1:Invoice/cac:OrderReference">
													<tr style="height:13px">
														<td align="left">
															<span style="font-weight:bold; ">
																<xsl:text>Sipariş No:</xsl:text>
															</span>
														</td>
														<td align="left">
															<xsl:for-each select="n1:Invoice/cac:OrderReference/cbc:ID">
																<xsl:apply-templates/>
															</xsl:for-each>
														</td>
													</tr>
												</xsl:if>
												<xsl:if test="//n1:Invoice/cac:OrderReference/cbc:IssueDate">
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
												</xsl:if>
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
						<table border="1" id="lineTable" width="800" cellspacing="0px" cellpadding="0px">
							<tbody>
								<tr id="lineTableTr">
									<td id="lineTableTd" style="width:2%">
										<span style="font-weight:bold; " align="center">
											<xsl:text>Sıra No</xsl:text>
										</span>
									</td>
									<td id="lineTableTd" style="width:10%">
										<span style="font-weight:bold; " align="center">
											<xsl:text>Referans No</xsl:text>
										</span>
									</td>	
									<td id="lineTableTd" style="width:8%">
										<span style="font-weight:bold; " align="center">
											<xsl:text>SM Kodu</xsl:text>
										</span>
									</td>
									<td id="lineTableTd" style="width:8%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Sut Kodu</xsl:text>
										</span>
									</td>
									<td id="lineTableTd" style="width:5%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Barkod</xsl:text>
										</span>
									</td>										
									<td id="lineTableTd" style="width:20%" align="center">
										<span style="font-weight:bold; ">
											<xsl:text>Malzeme/Hizmet Açıklaması</xsl:text>
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
									<td id="lineTableTd" style="width:9%" align="center">
										<span style="font-weight:bold; ">
											<xsl:text>İskonto Tutarı</xsl:text>
										</span>
									</td>
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
									<td id="lineTableTd" style="width:10%; " align="center">
										<span style="font-weight:bold; ">
											<xsl:text>Diğer Vergiler</xsl:text>
										</span>
									</td>
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
					<table id="notesTable" width="800" max-width="800" align="left" height="100" style="word-wrap:break-word;">
						<tbody width="800" max-width="800" style="word-wrap:break-word;">
							<tr align="left" max-width="800" style="word-wrap:break-word;">
								<td id="notesTableTd" width="800" max-width="800" style="word-wrap:break-word;">
									<xsl:for-each select="//n1:Invoice/cac:TaxTotal/cac:TaxSubtotal">
										<xsl:if test="cac:TaxCategory/cbc:TaxExemptionReasonCode!=''">
											<b>&#160;&#160;&#160;&#160;&#160; Vergi İstisna Muafiyet
												Sebebi: </b>
											<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReason"></xsl:value-of>
											<br />
										</xsl:if>
									</xsl:for-each>
									<xsl:for-each select="//n1:Invoice/cbc:Note">
										<xsl:value-of select="."></xsl:value-of>
										<br />
									</xsl:for-each>
									
								<xsl:for-each select="//n1:Invoice/cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
									<br />
									<b> Tevkifat Sebebi: </b>
									<xsl:value-of select="cbc:TaxTypeCode"></xsl:value-of>
									<xsl:text>-</xsl:text>
									<xsl:value-of select="cbc:Name"></xsl:value-of>
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
					<xsl:value-of select="./cac:Item/cac:SellersItemIdentification"></xsl:value-of>
				</td>
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cac:BuyersItemIdentification"></xsl:value-of>
				</td>	
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cbc:ModelName"></xsl:value-of>
				</td>				
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cac:ManufacturersItemIdentification"></xsl:value-of>
				</td>						
				<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Item/cbc:Name"></xsl:value-of>
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
				<td id="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
					<xsl:for-each select="cac:AllowanceCharge/cbc:Amount">
						<xsl:call-template name="Curr_Type"/>
					</xsl:for-each>
				</td>
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
				<td id="lineTableTd" style="font-size: xx-small" align="right">
					<xsl:text>&#160;</xsl:text>
					<xsl:for-each select="./cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
						<xsl:if test="cbc:TaxTypeCode!='0015' ">
							<xsl:text> </xsl:text>
							<xsl:value-of select="cbc:Name"/>
							<xsl:if test="../../cbc:Percent">
								<xsl:text> (%</xsl:text>
								<xsl:value-of select="format-number(../../cbc:Percent, '###.##0,00', 'european')"/>
								<xsl:text>)=</xsl:text>
							</xsl:if>
							<xsl:for-each select="../../cbc:TaxAmount">
								<xsl:call-template name="Curr_Type"/>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
					<xsl:for-each select="./cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
						<xsl:text>KDV TEVKİFAT </xsl:text>
						<xsl:if test="../../cbc:Percent">
							<xsl:text> (%</xsl:text>
							<xsl:value-of select="format-number(../../cbc:Percent, '###.##0,00', 'european')"/>
							<xsl:text>)=</xsl:text>
						</xsl:if>
						<xsl:for-each select="../../cbc:TaxAmount">
							<xsl:call-template name="Curr_Type"/>
							<xsl:text>&#10;</xsl:text>
						</xsl:for-each>
					</xsl:for-each>
				</td>
				<td id="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
					<xsl:for-each select="cbc:LineExtensionAmount">
						<xsl:call-template name="Curr_Type"></xsl:call-template>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:template>
		<xsl:template match="//cbc:IssueDate">
			<xsl:value-of select="substring(.,9,2)"></xsl:value-of>-<xsl:value-of select="substring(.,6,2)"></xsl:value-of>-<xsl:value-of select="substring(.,1,4)"></xsl:value-of>
			<xsl:value-of select="substring(.,11,6)"></xsl:value-of>
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
				<td id="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<!-- <td id="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td> -->
				<td id="lineTableTd" align="right">
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
				</td>	 -->			
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