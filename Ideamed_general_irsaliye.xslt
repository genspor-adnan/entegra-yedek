<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ccts="urn:un:unece:uncefact:documentation:2" xmlns:clm54217="urn:un:unece:uncefact:codelist:specification:54217:2001" xmlns:clm5639="urn:un:unece:uncefact:codelist:specification:5639:1988" xmlns:clm66411="urn:un:unece:uncefact:codelist:specification:66411:2001" xmlns:clmIANAMIMEMediaType="urn:un:unece:uncefact:codelist:specification:IANAMIMEMediaType:2003" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:link="http://www.xbrl.org/2003/linkbase" xmlns:n1="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2" xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" xmlns:xbrldi="http://xbrl.org/2006/xbrldi" xmlns:xbrli="http://www.xbrl.org/2003/instance" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:lcl="http://www.efatura.gov.tr/local" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="cac cbc ccts clm54217 clm5639 clm66411 clmIANAMIMEMediaType fn link n1 qdt udt xbrldi xbrli xdt xlink xs xsd xsi lcl">
	<xsl:character-map name="a"> 
		<xsl:output-character character="&#128;" string=""></xsl:output-character>
		<xsl:output-character character="&#129;" string=""></xsl:output-character>
		<xsl:output-character character="&#130;" string=""></xsl:output-character>
		<xsl:output-character character="&#131;" string=""></xsl:output-character>
		<xsl:output-character character="&#132;" string=""></xsl:output-character>
		<xsl:output-character character="&#133;" string=""></xsl:output-character>
		<xsl:output-character character="&#134;" string=""></xsl:output-character>
		<xsl:output-character character="&#135;" string=""></xsl:output-character>
		<xsl:output-character character="&#136;" string=""></xsl:output-character>
		<xsl:output-character character="&#137;" string=""></xsl:output-character>
		<xsl:output-character character="&#138;" string=""></xsl:output-character>
		<xsl:output-character character="&#139;" string=""></xsl:output-character>
		<xsl:output-character character="&#140;" string=""></xsl:output-character>
		<xsl:output-character character="&#141;" string=""></xsl:output-character>
		<xsl:output-character character="&#142;" string=""></xsl:output-character>
		<xsl:output-character character="&#143;" string=""></xsl:output-character>
		<xsl:output-character character="&#144;" string=""></xsl:output-character>
		<xsl:output-character character="&#145;" string=""></xsl:output-character>
		<xsl:output-character character="&#146;" string=""></xsl:output-character>
		<xsl:output-character character="&#147;" string=""></xsl:output-character>
		<xsl:output-character character="&#148;" string=""></xsl:output-character>
		<xsl:output-character character="&#149;" string=""></xsl:output-character>
		<xsl:output-character character="&#150;" string=""></xsl:output-character>
		<xsl:output-character character="&#151;" string=""></xsl:output-character>
		<xsl:output-character character="&#152;" string=""></xsl:output-character>
		<xsl:output-character character="&#153;" string=""></xsl:output-character>
		<xsl:output-character character="&#154;" string=""></xsl:output-character>
		<xsl:output-character character="&#155;" string=""></xsl:output-character>
		<xsl:output-character character="&#156;" string=""></xsl:output-character>
		<xsl:output-character character="&#157;" string=""></xsl:output-character>
		<xsl:output-character character="&#158;" string=""></xsl:output-character>
		<xsl:output-character character="&#159;" string=""></xsl:output-character>
	</xsl:character-map>
	<xsl:decimal-format name="european" decimal-separator="," grouping-separator="." NaN=""></xsl:decimal-format>
	<xsl:output version="4.0" method="html" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd" use-character-maps="a"></xsl:output>
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
					td.lineTableTd {
					    border-width: 1px;
					    padding: 1px;
					    border-style: inset;
					    border-color: black;
					    background-color: white;
					}
					tr.lineTableTr {
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
					td.lineTableBudgetTd {
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
				<title>e-İRSALİYE</title>
			</head>
			<body style="margin-left=0.6in; margin-right=0.6in; margin-top=0.79in; margin-bottom=0.79in">
				<xsl:for-each select="$XML">
					<table style="border-color:blue; " border="0" cellspacing="0px" width="800" cellpadding="0px">
						<tbody>
							<tr valign="top">
								<td width="40%">
									<br />
									<hr />
									<table align="center" border="0" width="100%">
										<tbody>
											<tr align="left">
												<xsl:for-each select="n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party">
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
												<xsl:for-each select="n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party">
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
											<xsl:if test="//n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:Contact/cbc:Telephone or //n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:Contact/cbc:Telefax">
												<tr align="left">
													<xsl:for-each select="n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party">														
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
											<xsl:for-each select="//n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cbc:WebsiteURI">
												<tr align="left">
												<td>
												<xsl:text>Web Sitesi: </xsl:text>
												<xsl:value-of select="."></xsl:value-of>
												</td>
												</tr>
											</xsl:for-each>
											<xsl:for-each select="//n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail">
												<tr align="left">
												<td>
												<xsl:text>E-Posta: </xsl:text>
												<xsl:value-of select="."></xsl:value-of>
												</td>
												</tr>
											</xsl:for-each>
											<tr align="left">
												<xsl:for-each select="n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party">																											
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
											<xsl:for-each select="//n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:PartyIdentification">
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
									<img style="width:91px;" align="middle" alt="E-Fatura Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/4QBoRXhpZgAASUkqAAgAAAADABIBAwABAAAAAQAAADEBAgAQAAAAMgAAAGmHBAABAAAAQgAAAAAAAABTaG90d2VsbCAwLjIyLjAAAgACoAkAAQAAAKYBAAADoAkAAQAAAKYBAAAAAAAA/+EJ9Gh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8APD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAtRXhpdjIiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyIgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSI0MjIiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSI0MjIiIHRpZmY6SW1hZ2VXaWR0aD0iNDIyIiB0aWZmOkltYWdlSGVpZ2h0PSI0MjIiIHRpZmY6T3JpZW50YXRpb249IjEiLz4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8P3hwYWNrZXQgZW5kPSJ3Ij8+/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUE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" />
									<h1 align="center">
										<span style="font-weight:bold; ">
											<xsl:text>e-İRSALİYE</xsl:text>
										</span>
									</h1>
									<!--İmza-->
								</td>
											<!--Logo-->
               	
							<td width="20%" align="center" valign="middle">
							<div id="qrcode"></div>
									<div id="qrvalue" style="display: none;">
										{
											"vkntckn": "<xsl:value-of select="n1:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID ='TCKN' or @schemeID = 'VKN']"></xsl:value-of>",
											"avkntckn": "<xsl:value-of select="n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID ='TCKN' or @schemeID = 'VKN']"></xsl:value-of>",
											"senaryo": "<xsl:value-of select="n1:DespatchAdvice/cbc:ProfileID"></xsl:value-of>",
											"tip": "<xsl:value-of select="n1:DespatchAdvice/cbc:DespatchAdviceTypeCode"></xsl:value-of>",
											"tarih": "<xsl:value-of select="n1:DespatchAdvice/cbc:IssueDate"></xsl:value-of>",
											"no": "<xsl:value-of select="n1:DespatchAdvice/cbc:ID"></xsl:value-of>",
											"ettn": "<xsl:value-of select="n1:DespatchAdvice/cbc:UUID"></xsl:value-of>",
											"sevktarihi": "<xsl:value-of select="n1:DespatchAdvice/cac:Shipment/cac:Delivery/cac:Despatch/cbc:ActualDespatchDate"></xsl:value-of>",
											"sevkzamani": "<xsl:value-of select="n1:DespatchAdvice/cac:Shipment/cac:Delivery/cac:Despatch/cbc:ActualDespatchTime"></xsl:value-of>",
											"tasiyicivkn": "<xsl:value-of select="n1:DespatchAdvice/cac:Shipment/cac:Delivery/cac:CarrierParty/cac:PartyIdentification/cbc:ID"></xsl:value-of>",
											"plaka": "<xsl:value-of select="n1:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cac:TransportMeans/cac:RoadTransport/cbc:LicensePlateID"></xsl:value-of>"
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
								  <img style="width:240px;" align="center" alt="Company Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAIhBMcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigApCKKq6nK0OnXUinBWNiD7gGmldpEylypy7FgMGGRgj2NKa/Pvw/+1b428H+KpZp501bTUlKy6dOAolAPJV+qNgHBwRnGQe32t8OPil4d+Kmif2l4fvluVXC3Fu3yzW7kZ2SL2PvyD1BI5r2MdlOIwCU5q8X1R8/lueYTM5Sp03aS6P8AQ7Cikpa8Y+iCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooATvVDXDjR789vIf/wBBNX+9UNe/5At/2/cSc/8AATVw+NeplV+CXoflTrSkaxejAJMrdBnPI/l/Wr3g3xtrPw/8QQa5oWoSadew5BK5McqHrHIhwHU4B2noQCCCARS1pidYveoxMwx3zk8/yP4VSUkDGO4PU4H6Y4B6Cv39U41aKhNJprY/l11Z0cQ6lN2kn+p+i/wQ/aB0b4u6ZDbvJDYeJI4w1xp4clW7F4mIG5fbqvQ9ifWc1+Sun3lxpt5b3VrcSWs0MiyxzQylHRlYEMpByCCAQe30r7A+BH7YUGrSQ6B4+njs71vlt9cO2OCY5xsmAwI36YYAK3P3TgH8zzfh2eHvWwqvDquq/wCAfsGRcVU8XbD4x8s+j6P/ACZ9WUUgIYZByKWviT9HCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBBVHXv+QLf/APXB/wD0E1eFZ/iA7dC1E+lvIc/8BNXD4l6mVX4Jeh+VWuDOr3oJyDMwJPoSeelUgc4IGfoODjFXtdGNXvQeAZXzznjJB4qkSxzkgnByR1PuO30x6iv6Cp/BH0P5Yrfx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bi0Y5IEiAnGcHDAlTg4Jwa/I80yatlsub4oPZ/5n7tk2f4fNY8vw1Fuv8ju6KKK+fPqgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/WszxL/AMi9qf8A16yf+gmtM/1rM8S/8i9qf/XrJ/6CauHxr1Mav8OXoz8rtdz/AGzf55HnuQQePvHj+X0zVHkAbSBjnDcDPGfp9Pb8ruunbrV8OSRPIcj03E4zniqIG0AjAz0wDjHtX9BU/gj6I/lmt/El6scPlYZBOSAVyCc9cHOPfp+VIBtyMYY4HA46f4UALkjII6Accc9MfmaVSQ3IJPXGSR69+3+PvVmA3gYxySM9euecZ68/X0oB3An5cdDx+Ayffj8qAB3IIIxn+Z5HOBSqW3A/MDk5HTPfPvnH8verBbigHftPBxjAOSeeSP06e/1pow3Q4JGOoxk85/LB59qOBgk8A+nX/Hgdh+dBYgn3OcZ4/r6Y/A4zQAA7iDgY7HI9yOv1NGOcEdcfnxx/P/PNGQWPIGB1Uk9xkfTBFLknrtJJAJ/Tn17VACFuDnOD14ye+Oenc/l+Wv4W8Wax4J1yDV9Fv5tM1GHgXEXUpkEqwPysmcZVgQcZxnmshWyoOM8bsdiQCB+lBHGAMkZAAzyPQZ79T+FTOEakXCaTT3TNaVSdGaqU3ZrqfoN8Bv2l9I+LEUOlaiItI8VhCWsyx8u5C9XhJ68clCSyjP3gN1e2H86/JBJ3hlWWKV4njYOksTsjowOQysuCGB5BBBBxivrz9n/9rb7QIPDvjy5VZ94itdbPyqwwMLcdlYHI8zhSMbsEEn8yzfh6VC9fCK8eq6r07o/ZMh4qjibYbGu0uj6M+taKarBwCCCDzxTq+GP0rcKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBPSs3xL/AMi7qX/XtJ/6Aa0vSs3xJx4e1I/9O0n/AKCauHxr1Mav8OXoflbrWRrV9gY/fuRznPzH8+cVQ9epycHGMnoP6Cr2uAf2xegEE/aJDj/gWQPrVFSMg4B5656/j7569a/oKl8MfRH8sVv4kvV/mJkqCT14yOuRnIzTvuEEEDng9O/T64Ht+dJglQD6YzySPfj2oDEtgcc+vAGeff8A+titjEUZzgjGTkkDjjHIHUn+tIoHpkdODjnuMDv9O9IvA4JOARkdccZ6fX+VLkKGPQD1HX3yOw4+lACjPBHTvweuT744xRkgg5wcgEE56DPU9+evf8aMbSTgKQSuepwD/jn8evNA+UA4OM8AgnoePoM4Pp0oATJGCDzjsecdcc45z36UYyQAR6DrkHpkUAAZHAIzgEZ4wAef89DSrjdwCDweBg9/QZ78Zx9KgBM56HPORkY5J6epyP0xQpBPygHvnOR3/DjB9/50KR8pAyOc9+OOxH+c0DICknPbk9Tj0HX8PTirGKTkHOc47nr6c59fXmhGKnKkAEkBuMEHqOvp29D+aD5uMZHQe4H4cc9evT8lySDjAU5PJwOeB+px65zQHoe6fAj9qLVPhdImj64J9X8MDbGkI5uLLnGYycbkx1jPIxlT1B+5/DHinSfGmg2ms6Hfxalpl2u+G5gbKtzgg+hBBBBwQQQQCCK/KQMByDyvAJPbnPX8P84rs/hV8XfEPwg17+0dEnElnI3+maXOzfZ7pfcDJRwOkgBI6EMMg/E5vw/DFXrYbSfVdH/kz9DyLimpgrYfFvmh36r/ADR+n2eaP0rhPhN8YNA+MGgm/wBHmMdzAQl3YTYE1s5GcMO4PUMMg9jwQO7xjmvy6pTnSm6dRWaP2ijWp4iCqUneL6jqKKKzNwooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/AFrM8S/8i9qf/XrJ/wCgmtM/1rM8S/8AIvan/wBesn/oJq4fGvUxq/w5ejPyu1zI1q+wTkzuAc8nkjt6/wBKocgEknJGBk4/H/OOlXtbymr35JP+vckknj5j/Lr/AI1SXsDk8kcHoc4Pb3r+gqf8Neh/K9b+JL1YhzhsEk8nnJIHpz9OlBYDJ/hHPTJAHvxz+lO3YORwB0Ax+JB9sH/JFIDhs53Ht2HtjjrjP5VsZCYK8ZwRwCOCO/07Zx+lLnacgEgHAyc9uAD9KQAAjAIGOcg8dR3/AJ0KcEnocAnHU845H+evvQAbeMDoCBnOfbHf3pdvzYwSoGM569D7/Q96QAbuDz0AwO564HUe/qaOjDKjsQDjPfsM0AA4JIUDPYc++M898fkKaByDgYBIODk98n888Dt6UowCSMZx1H4nOffP8vpS7icjJB5GCMH9PT0oABkkEg5zg9x3xSAkqADk4xwQeOM8/wCPb0pRkMMEBhwODnr/APqGfQ0nJwSQp65IAx15/l9MUAKOeAvoQcE8fl6YPr2oGcYxk9fbPt/nkj2oBG4emQDwc9CQD7c9+4xz0oAwFyAD6DGDwc4B6445+nSgAAypGOMEEAHH4/55BFLyc889eeTnn09s/lmkADAdgBnOBx0xjuO2SfSjkgZBOBnJwAPXjtx9fwoA2fC3irV/BGu22saJfS6df2zHbLGeCD1RlPDKePlYHOAeCAR9+/AL4+6d8ZdGMExisvFFnErX2noSFIPHmxZ5KE9uSp4P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9Tz+Z9Kbwc52+5JxgA9D+OBS84IGSc8HJIJPcduw6e3NBUDIHK8gYx06c9unamgAg5Jwc5ye2Tnkd+fXrikAG3jjoMAk8A/ywaANxzgDODwOMelKCG64J6jcDk9Tx6+nXrVDPT/2XD/xkL4IIwc3F1kA9P8AQbmv0kFfm5+y8Qf2g/AmARm5ujzjP/HjdenB/wDr1+kY6mvyfiv/AH6K/ur82fuPBP8AyLpf4n+SFooor4w/QQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGjp+NZviT/kXtT/69pP/AEE1pDp+NZ3iNd2gakPW2kH/AI6aqn8a9TGt/Dl6M/KvWh/xOL3dlR58nQnPU9/Tpx3qlndyFIJGcAdOO1XdbI/tm9xkjz2B5z/EcjHT+vWqR6HAx1BAHtX9CU/gj6H8s1v4kvVhnJI69D0OTnPPuKO/pk88EjrjGOv4fj1oYHO0nAzjI9P69eMAfhRnJXOSD0498Y/Dj8CK1MUAGB8xHtnOPUj+h+oowCeM8Y5B5xn6d/8AGgAqoBBAzjpwenOB+P8AgMUhztIzhgDx0GcZ59cYH+c0CHBiCDngckgAd+OfX6f/AKk2kDByR0yRxjrn9APT8aOVGRuAxwepx179epoxjOTgkgE4/wD1DIHX60ABwWJPI688579fX1zQepGTgjGTgZ6/r9M9aQgMpIABI7LnH6DsP1HpTlB7DJ6kgdRk/njNTcBqgYHoccg5GSec/h+mfSgMcAnggHljk/8A6x6f4UYwOSCSMkA8HH5cEHng0pBByMnn0Jz6A5+n6VQCfiTweBwCfpzzk9ewpSDnOcN1BAwM8gds9zwPxoBxjkjnGenYHIz05Of60c5IAJA5IIz78c9O+PwoAQD5SDx9Dnk//qpSMEEZJwSCRyMf/X96QIAf73Xg8j8z34//AFUnPclgBgkHg46/nn68fjUoNwUjAGB1AJyD+RHHP9D9KXAJJzk9OfTHXJ/DmlJPJz6kcYyM/wA8/wCetISQCCMEAjJHB4/yfxqikeofswAD9obwKfW6usdP+fC5/LpX6SDpX5u/svj/AIyF8DDA+W4ujkf9eNyP8/Sv0jr8m4r/AN9j/hX5s/ceCv8AkXS/xP8AJBRRRXxp+gDSeKOtH1OKwdf8a6N4at/Ov71EUnAVMufyGcfU1UYSm+WKuZzqQprmm0l5m9096Bn2rxrxJ+0dp2n3KxaZa/boyMmVn246cAYx365rzfVvj74ru7pntL/7FCTlYlgjIA9MlST2716tHKsTVV7W9Twa+fYOg7X5vQ+rc0ZNfL/hz9o3X9NlYaoY9VjOcBo1jKjtyoGPxBr1PwZ8edA8TLHDfMNEvpGKpFcyAxvzxtk4HpwwBycAGor5biaCbcbpdjTDZ1g8S1FSs/P+rHp9FICCAQcilryz3gooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKr3kC3VpNE33ZEZD9CMVYpMCmnZ3JaurH5OeIbSay1i7S5RonWeRWRuCpDlTx16g9R196oAc44A6EnoTxwR6epPv7V9A/tk+ERoHxCt7i2tXitr6KS78xUO1nLASc4xkE5IzxuB718+5BAGQATz1B74/l+tfvOX4mOLw0Ky6o/mTNMLLBYypQl0YnKnAGCexJz64J7/j9KUEDBGGA43e4Gceh4I49fpmhcgZyB2AU9O2c9fz9+1JuAIHfIOO4A5zj0616J5IFQASclSMgg8YyP/rUpJYgZwSc4HcZ6j1xz+eKNu0YIA9DgjPQgDHGeP8AOKTOSATg/TgH0PfJ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QHOSBgMcEnGM9ufQ9OPYetIcDIwx69eB+Z6f40gBOcgHOR0wR+nHAP50obAJBHqefX3HX8KBnQ/D/wD5HbShknmUE8gkGJ85/X15wOnT1wA5UDknnPAB4wMg4yPy715B4AUJ410nA6NJwSc/6mTtg+3+eT69tBTAAIweoA5B6+3ABP0968DH/wAVeh9Dl/8ACfr/AJDlIHBwMADocH0Pb27/AMqFztA5z04ORk9CMjI7jv8AzpMEcAjkjgcYPJz07fp9KARkDCggDOBnGTwCB9OnvXlnqXAfNggBlOMkHjHYH8OMf/WyoXDAjnHQ/p14J7Yx60n8QI5Y5AIAJ9QO/AyfypQTkHPIORgkBvTn6Z9+hoAQkIPlyBjGDzgc5+oIOe3fvTjkMckjkdRx268nPI/A5+tJt3EcZ7AjkdwevsaANwwT8uRyT1zx1P5fWncSA85HJOBnJ68+p/D/AOv1o4BIJAUDBwBwPqe3Sk2jJZs5ABPPJ9Ce3pj0zTud2CGOSOM9TnqTzwf5/SkMaCeDkZGCAozk4yOfUHsOacBtyM5xxkcjjnPXoOKQHOSG4A5JOQT17e3fjk045GQe3UkEHgAnHbqfTv70/ILFzSNWv9A1CK/066e0vYifLnQglQeoIPBBwMggg+nSvpH4YfHKw8YNFpmq7NM1knbEpb93dH1Q9m9UPPpkZx8wnO45ABzwAM44A4Azk4/pTSofIPIBPGcEdxjuCCOCORjPpXnYvA0sXH3lZ9z1svzOvl87wd49Ufe3Wg8184/Cv49zaU0WleJ55LmzAVIdQYFpo+373u6/7YyRj5s8kfRFtcRXcEc0MiywyKGSRGBVgeQQR1FfB4nCVcJPlqI/UsDj6OPp89N69V1RYooorjPTCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGgUtQT3UNpHvnmjiUfxOwUfn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HJAY8jGfb064/WgAwuTkDgYJbkjn8eOcnJpSSTk5BYcg5546H1H59eaTIzwAMDgZ9DwB6dvagAEsABtyeMHgd+3HPp6fjQFwJJIAOR65yccke46HPP6UDPbg5OM8n64/D9elOJPJfhjjJyMA9jg/y/GmrjK8qOpBHXqTwfzFABtBYZClegA9OOCQPrke1AO4gHgkjJJA7dM54HXnHNJuA24Iz/tYXPfj8genp68KMhlOOd2AeM9Ccc8Dkk56dck44AFJJXGTk9DnByenr7c9uKUc5IA7dzz1xk/T+YpqklQR90jqMADjnHbr707ALYwAG46HA5z6dvQdfyNAIQ8E5XI7AkZ4/r7ewqSCeW1uY5IpHhmikDo8bFXVgcggg5BHGCOaiJwoIBBwcA8HnjOOmMfrRkbjjoDjGQBxjjPrn+ZzSavoxptO6PfPhj+0GsjR6X4ukS3lPEWq4CRvyAFlH8Dc/eHynvtOM+8Bgygg5FfBPXcpAIJwVJ4IOODkemeO9emfCr4z33gh4dO1Fn1DQM7VXO6W1HYocncn+x2BG04G0/LY/KU06uHXqv8AI+3yrP3Fqji3p0f+f+Z9VUDn6VnaLrlj4j0y31DTrqO8sp13RzRnIYf4g8YPQ5BrRAr5Jpx0Z+gxkppSi7odRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAaBSZ5rzb4rfHXQvhTA6XY+1aiBuS0D7N3AP3iD6jsetfP+uft0Xt3ayx6doq2UzA+XIriUr05O4AH8q9jC5RjMZFTpQ93ufP43PcBgJOFap7y6I+yunfFULrX9OslYz31vGV6gyDNfnve/tUfEK6Zx/bR2SAgq0ak85zwAABj2rzrVPFer6vc+fdX85csSQrFRz1PHHP9DX0VHhStJ/vZpLyPlMRxth4q1Cm2/PQ+/PEf7U3gXQftkK6j9ovbclRBtK729Acf0rxXxJ+3Ff3du8Wl6SLGU9JQ4f6feH64r5WLM7A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Kw4x34/TrzXMFd31Poc/56ikB+YjH1x2/wAM0+WxtGnBdC/ea7qV+CLi/nZSMFA+xcEdMLgY61QRFHIAGe+MdvWlwQcdOuO3+c0cAHIzjqCP0/XpVWNfJAOSM4J9T649OaQqAOgPuPX6/pTumOM+/wCPY/lQD0PGevNUK43ueScc5Hf/ADmpI3aCeGaN2jkhdZY5ImKtG6kFXUjkMCAQRyCKZzx2wSOKRhkkY69s98cmoaTVmXFuLTi7NH6u/sefHWX44fCiCfV7mGXxXpEn2HVRGFUysBmO42A/KJEwTwBvEgAAXFe79K/L3/gn341m8NftEw6MZJBa+I9MntHhVsK0sI8+JyO5VFuFH/XQ1+oNfh+d4JYHGyhFe69V6M/dslxjxuChUlutH8h1FFFeEe6FFFFABRSDmq15qVrYAfabqG3B6GWQLn8zTSb0RLaW5aoqlaavZX7Fbe8t7hhyRFKrH9DVwmhprRgmnsLRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGnmvFPj9+zZpnxdtJdS09otM8UxxFYblwfJuCB8qTAAnHAG8Aso/vAba9ro610YfEVcLUVWk7NHHisLRxlJ0a8bpn5R+LPB+ueBNdn0XXtOm0vUI1BMcoysino8bj5ZFOCNy8A5BwQQMc46HIKnA4+6O/b+f8uK/U3x/8N/DvxN0b+zPEWmQ6hbq2+J2+WSB+zxuMMrdsgjIyDkEivkH4h/sO+J9AkkufB+ow+JbEAkWWoSLb3i8jCh8eW56kk+XwMc1+n5dxJQrpQxL5Jfg/wDL5n45m3CWJwsnUwi54duv/B+R84A5XhSMDA5PTrjPTHP8/egHHTj1JGDz6/pyD3+tbXiPwD4q8GtcDXfDOsaYkDbXnnsZTBnnOJkDRkY6ENiuaOp2IYgXtuCOCTKA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" />
								  <br />
								</div>
							</td></tr>
							<tr style="height:118px; " valign="top">
								<td width="40%" align="right" valign="bottom">
									<table id="customerPartyTable" align="left" border="0">
										<tbody>
											<tr style="height:71px; ">
												<td>
												<hr />
												<table align="center" border="0">
												<tbody>
												<tr>
												<xsl:for-each select="n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party">
													<td style="width:469px; " align="left">
														<span style="font-weight:bold; ">
															<xsl:text>SAYIN</xsl:text>
														</span>
													</td>
												</xsl:for-each>													
												</tr>
												<tr>
													<xsl:choose>
														<xsl:when test="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and text()='TAXFREE']">
															<xsl:for-each select="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party">
																<xsl:call-template name="Party_Title">
																	<xsl:with-param name="PartyType">TAXFREE</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:when>
														<xsl:when test="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and starts-with(text(), 'EXPORT')]">
															<xsl:for-each select="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party">
																<xsl:call-template name="Party_Title">
																	<xsl:with-param name="PartyType">EXPORT</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party">
																<xsl:call-template name="Party_Title">
																	<xsl:with-param name="PartyType">OTHER</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:otherwise>
													</xsl:choose>													
												</tr>
													<xsl:choose>
														<xsl:when test="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and text()='TAXFREE']">
																<xsl:for-each select="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party">
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
														<xsl:when test="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE' and starts-with(text(), 'EXPORT')]">
															<xsl:for-each select="n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party">
																<tr>
																	<xsl:call-template name="Party_Adress">
																		<xsl:with-param name="PartyType">EXPORT</xsl:with-param>
																	</xsl:call-template>
																</tr>
																<xsl:call-template name="Party_Other">
																	<xsl:with-param name="PartyType">EXPORT</xsl:with-param>
																</xsl:call-template>
															</xsl:for-each>															
														</xsl:when>
														<xsl:otherwise>
															<xsl:for-each select="n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party">
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
<!-- 								<td width="40%" align="center" valign="middle">								
										<img style="width:220px;" align="center" alt="Company Logo" src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAIhBMcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9U6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigApCKKq6nK0OnXUinBWNiD7gGmldpEylypy7FgMGGRgj2NKa/Pvw/+1b428H+KpZp501bTUlKy6dOAolAPJV+qNgHBwRnGQe32t8OPil4d+Kmif2l4fvluVXC3Fu3yzW7kZ2SL2PvyD1BI5r2MdlOIwCU5q8X1R8/lueYTM5Sp03aS6P8AQ7Cikpa8Y+iCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooATvVDXDjR789vIf/wBBNX+9UNe/5At/2/cSc/8AATVw+NeplV+CXoflTrSkaxejAJMrdBnPI/l/Wr3g3xtrPw/8QQa5oWoSadew5BK5McqHrHIhwHU4B2noQCCCARS1pidYveoxMwx3zk8/yP4VSUkDGO4PU4H6Y4B6Cv39U41aKhNJprY/l11Z0cQ6lN2kn+p+i/wQ/aB0b4u6ZDbvJDYeJI4w1xp4clW7F4mIG5fbqvQ9ifWc1+Sun3lxpt5b3VrcSWs0MiyxzQylHRlYEMpByCCAQe30r7A+BH7YUGrSQ6B4+njs71vlt9cO2OCY5xsmAwI36YYAK3P3TgH8zzfh2eHvWwqvDquq/wCAfsGRcVU8XbD4x8s+j6P/ACZ9WUUgIYZByKWviT9HCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBBVHXv+QLf/APXB/wD0E1eFZ/iA7dC1E+lvIc/8BNXD4l6mVX4Jeh+VWuDOr3oJyDMwJPoSeelUgc4IGfoODjFXtdGNXvQeAZXzznjJB4qkSxzkgnByR1PuO30x6iv6Cp/BH0P5Yrfx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bi0Y5IEiAnGcHDAlTg4Jwa/I80yatlsub4oPZ/5n7tk2f4fNY8vw1Fuv8ju6KKK+fPqgooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/WszxL/AMi9qf8A16yf+gmtM/1rM8S/8i9qf/XrJ/6CauHxr1Mav8OXoz8rtdz/AGzf55HnuQQePvHj+X0zVHkAbSBjnDcDPGfp9Pb8ruunbrV8OSRPIcj03E4zniqIG0AjAz0wDjHtX9BU/gj6I/lmt/El6scPlYZBOSAVyCc9cHOPfp+VIBtyMYY4HA46f4UALkjII6Accc9MfmaVSQ3IJPXGSR69+3+PvVmA3gYxySM9euecZ68/X0oB3An5cdDx+Ayffj8qAB3IIIxn+Z5HOBSqW3A/MDk5HTPfPvnH8verBbigHftPBxjAOSeeSP06e/1pow3Q4JGOoxk85/LB59qOBgk8A+nX/Hgdh+dBYgn3OcZ4/r6Y/A4zQAA7iDgY7HI9yOv1NGOcEdcfnxx/P/PNGQWPIGB1Uk9xkfTBFLknrtJJAJ/Tn17VACFuDnOD14ye+Oenc/l+Wv4W8Wax4J1yDV9Fv5tM1GHgXEXUpkEqwPysmcZVgQcZxnmshWyoOM8bsdiQCB+lBHGAMkZAAzyPQZ79T+FTOEakXCaTT3TNaVSdGaqU3ZrqfoN8Bv2l9I+LEUOlaiItI8VhCWsyx8u5C9XhJ68clCSyjP3gN1e2H86/JBJ3hlWWKV4njYOksTsjowOQysuCGB5BBBBxivrz9n/9rb7QIPDvjy5VZ94itdbPyqwwMLcdlYHI8zhSMbsEEn8yzfh6VC9fCK8eq6r07o/ZMh4qjibYbGu0uj6M+taKarBwCCCDzxTq+GP0rcKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBPSs3xL/AMi7qX/XtJ/6Aa0vSs3xJx4e1I/9O0n/AKCauHxr1Mav8OXoflbrWRrV9gY/fuRznPzH8+cVQ9epycHGMnoP6Cr2uAf2xegEE/aJDj/gWQPrVFSMg4B5656/j7569a/oKl8MfRH8sVv4kvV/mJkqCT14yOuRnIzTvuEEEDng9O/T64Ht+dJglQD6YzySPfj2oDEtgcc+vAGeff8A+titjEUZzgjGTkkDjjHIHUn+tIoHpkdODjnuMDv9O9IvA4JOARkdccZ6fX+VLkKGPQD1HX3yOw4+lACjPBHTvweuT744xRkgg5wcgEE56DPU9+evf8aMbSTgKQSuepwD/jn8evNA+UA4OM8AgnoePoM4Pp0oATJGCDzjsecdcc45z36UYyQAR6DrkHpkUAAZHAIzgEZ4wAef89DSrjdwCDweBg9/QZ78Zx9KgBM56HPORkY5J6epyP0xQpBPygHvnOR3/DjB9/50KR8pAyOc9+OOxH+c0DICknPbk9Tj0HX8PTirGKTkHOc47nr6c59fXmhGKnKkAEkBuMEHqOvp29D+aD5uMZHQe4H4cc9evT8lySDjAU5PJwOeB+px65zQHoe6fAj9qLVPhdImj64J9X8MDbGkI5uLLnGYycbkx1jPIxlT1B+5/DHinSfGmg2ms6Hfxalpl2u+G5gbKtzgg+hBBBBwQQQQCCK/KQMByDyvAJPbnPX8P84rs/hV8XfEPwg17+0dEnElnI3+maXOzfZ7pfcDJRwOkgBI6EMMg/E5vw/DFXrYbSfVdH/kz9DyLimpgrYfFvmh36r/ADR+n2eaP0rhPhN8YNA+MGgm/wBHmMdzAQl3YTYE1s5GcMO4PUMMg9jwQO7xjmvy6pTnSm6dRWaP2ijWp4iCqUneL6jqKKKzNwooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigBD/AFrM8S/8i9qf/XrJ/wCgmtM/1rM8S/8AIvan/wBesn/oJq4fGvUxq/w5ejPyu1zI1q+wTkzuAc8nkjt6/wBKocgEknJGBk4/H/OOlXtbymr35JP+vckknj5j/Lr/AI1SXsDk8kcHoc4Pb3r+gqf8Neh/K9b+JL1YhzhsEk8nnJIHpz9OlBYDJ/hHPTJAHvxz+lO3YORwB0Ax+JB9sH/JFIDhs53Ht2HtjjrjP5VsZCYK8ZwRwCOCO/07Zx+lLnacgEgHAyc9uAD9KQAAjAIGOcg8dR3/AJ0KcEnocAnHU845H+evvQAbeMDoCBnOfbHf3pdvzYwSoGM569D7/Q96QAbuDz0AwO564HUe/qaOjDKjsQDjPfsM0AA4JIUDPYc++M898fkKaByDgYBIODk98n888Dt6UowCSMZx1H4nOffP8vpS7icjJB5GCMH9PT0oABkkEg5zg9x3xSAkqADk4xwQeOM8/wCPb0pRkMMEBhwODnr/APqGfQ0nJwSQp65IAx15/l9MUAKOeAvoQcE8fl6YPr2oGcYxk9fbPt/nkj2oBG4emQDwc9CQD7c9+4xz0oAwFyAD6DGDwc4B6445+nSgAAypGOMEEAHH4/55BFLyc889eeTnn09s/lmkADAdgBnOBx0xjuO2SfSjkgZBOBnJwAPXjtx9fwoA2fC3irV/BGu22saJfS6df2zHbLGeCD1RlPDKePlYHOAeCAR9+/AL4+6d8ZdGMExisvFFnErX2noSFIPHmxZ5KE9uSp4P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9Tz+Z9Kbwc52+5JxgA9D+OBS84IGSc8HJIJPcduw6e3NBUDIHK8gYx06c9unamgAg5Jwc5ye2Tnkd+fXrikAG3jjoMAk8A/ywaANxzgDODwOMelKCG64J6jcDk9Tx6+nXrVDPT/2XD/xkL4IIwc3F1kA9P8AQbmv0kFfm5+y8Qf2g/AmARm5ujzjP/HjdenB/wDr1+kY6mvyfiv/AH6K/ur82fuPBP8AyLpf4n+SFooor4w/QQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGjp+NZviT/kXtT/69pP/AEE1pDp+NZ3iNd2gakPW2kH/AI6aqn8a9TGt/Dl6M/KvWh/xOL3dlR58nQnPU9/Tpx3qlndyFIJGcAdOO1XdbI/tm9xkjz2B5z/EcjHT+vWqR6HAx1BAHtX9CU/gj6H8s1v4kvVhnJI69D0OTnPPuKO/pk88EjrjGOv4fj1oYHO0nAzjI9P69eMAfhRnJXOSD0498Y/Dj8CK1MUAGB8xHtnOPUj+h+oowCeM8Y5B5xn6d/8AGgAqoBBAzjpwenOB+P8AgMUhztIzhgDx0GcZ59cYH+c0CHBiCDngckgAd+OfX6f/AKk2kDByR0yRxjrn9APT8aOVGRuAxwepx179epoxjOTgkgE4/wD1DIHX60ABwWJPI688579fX1zQepGTgjGTgZ6/r9M9aQgMpIABI7LnH6DsP1HpTlB7DJ6kgdRk/njNTcBqgYHoccg5GSec/h+mfSgMcAnggHljk/8A6x6f4UYwOSCSMkA8HH5cEHng0pBByMnn0Jz6A5+n6VQCfiTweBwCfpzzk9ewpSDnOcN1BAwM8gds9zwPxoBxjkjnGenYHIz05Of60c5IAJA5IIz78c9O+PwoAQD5SDx9Dnk//qpSMEEZJwSCRyMf/X96QIAf73Xg8j8z34//AFUnPclgBgkHg46/nn68fjUoNwUjAGB1AJyD+RHHP9D9KXAJJzk9OfTHXJ/DmlJPJz6kcYyM/wA8/wCetISQCCMEAjJHB4/yfxqikeofswAD9obwKfW6usdP+fC5/LpX6SDpX5u/svj/AIyF8DDA+W4ujkf9eNyP8/Sv0jr8m4r/AN9j/hX5s/ceCv8AkXS/xP8AJBRRRXxp+gDSeKOtH1OKwdf8a6N4at/Ov71EUnAVMufyGcfU1UYSm+WKuZzqQprmm0l5m9096Bn2rxrxJ+0dp2n3KxaZa/boyMmVn246cAYx365rzfVvj74ru7pntL/7FCTlYlgjIA9MlST2716tHKsTVV7W9Twa+fYOg7X5vQ+rc0ZNfL/hz9o3X9NlYaoY9VjOcBo1jKjtyoGPxBr1PwZ8edA8TLHDfMNEvpGKpFcyAxvzxtk4HpwwBycAGor5biaCbcbpdjTDZ1g8S1FSs/P+rHp9FICCAQcilryz3gooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKr3kC3VpNE33ZEZD9CMVYpMCmnZ3JaurH5OeIbSay1i7S5RonWeRWRuCpDlTx16g9R196oAc44A6EnoTxwR6epPv7V9A/tk+ERoHxCt7i2tXitr6KS78xUO1nLASc4xkE5IzxuB718+5BAGQATz1B74/l+tfvOX4mOLw0Ky6o/mTNMLLBYypQl0YnKnAGCexJz64J7/j9KUEDBGGA43e4Gceh4I49fpmhcgZyB2AU9O2c9fz9+1JuAIHfIOO4A5zj0616J5IFQASclSMgg8YyP/rUpJYgZwSc4HcZ6j1xz+eKNu0YIA9DgjPQgDHGeP8AOKTOSATg/TgH0PfJ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QHOSBgMcEnGM9ufQ9OPYetIcDIwx69eB+Z6f40gBOcgHOR0wR+nHAP50obAJBHqefX3HX8KBnQ/D/wD5HbShknmUE8gkGJ85/X15wOnT1wA5UDknnPAB4wMg4yPy715B4AUJ410nA6NJwSc/6mTtg+3+eT69tBTAAIweoA5B6+3ABP0968DH/wAVeh9Dl/8ACfr/AJDlIHBwMADocH0Pb27/AMqFztA5z04ORk9CMjI7jv8AzpMEcAjkjgcYPJz07fp9KARkDCggDOBnGTwCB9OnvXlnqXAfNggBlOMkHjHYH8OMf/WyoXDAjnHQ/p14J7Yx60n8QI5Y5AIAJ9QO/AyfypQTkHPIORgkBvTn6Z9+hoAQkIPlyBjGDzgc5+oIOe3fvTjkMckjkdRx268nPI/A5+tJt3EcZ7AjkdwevsaANwwT8uRyT1zx1P5fWncSA85HJOBnJ68+p/D/AOv1o4BIJAUDBwBwPqe3Sk2jJZs5ABPPJ9Ce3pj0zTud2CGOSOM9TnqTzwf5/SkMaCeDkZGCAozk4yOfUHsOacBtyM5xxkcjjnPXoOKQHOSG4A5JOQT17e3fjk045GQe3UkEHgAnHbqfTv70/ILFzSNWv9A1CK/066e0vYifLnQglQeoIPBBwMggg+nSvpH4YfHKw8YNFpmq7NM1knbEpb93dH1Q9m9UPPpkZx8wnO45ABzwAM44A4Azk4/pTSofIPIBPGcEdxjuCCOCORjPpXnYvA0sXH3lZ9z1svzOvl87wd49Ufe3Wg8184/Cv49zaU0WleJ55LmzAVIdQYFpo+373u6/7YyRj5s8kfRFtcRXcEc0MiywyKGSRGBVgeQQR1FfB4nCVcJPlqI/UsDj6OPp89N69V1RYooorjPTCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGgUtQT3UNpHvnmjiUfxOwUfn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HJAY8jGfb064/WgAwuTkDgYJbkjn8eOcnJpSSTk5BYcg5546H1H59eaTIzwAMDgZ9DwB6dvagAEsABtyeMHgd+3HPp6fjQFwJJIAOR65yccke46HPP6UDPbg5OM8n64/D9elOJPJfhjjJyMA9jg/y/GmrjK8qOpBHXqTwfzFABtBYZClegA9OOCQPrke1AO4gHgkjJJA7dM54HXnHNJuA24Iz/tYXPfj8genp68KMhlOOd2AeM9Ccc8Dkk56dck44AFJJXGTk9DnByenr7c9uKUc5IA7dzz1xk/T+YpqklQR90jqMADjnHbr707ALYwAG46HA5z6dvQdfyNAIQ8E5XI7AkZ4/r7ewqSCeW1uY5IpHhmikDo8bFXVgcggg5BHGCOaiJwoIBBwcA8HnjOOmMfrRkbjjoDjGQBxjjPrn+ZzSavoxptO6PfPhj+0GsjR6X4ukS3lPEWq4CRvyAFlH8Dc/eHynvtOM+8Bgygg5FfBPXcpAIJwVJ4IOODkemeO9emfCr4z33gh4dO1Fn1DQM7VXO6W1HYocncn+x2BG04G0/LY/KU06uHXqv8AI+3yrP3Fqji3p0f+f+Z9VUDn6VnaLrlj4j0y31DTrqO8sp13RzRnIYf4g8YPQ5BrRAr5Jpx0Z+gxkppSi7odRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAaBSZ5rzb4rfHXQvhTA6XY+1aiBuS0D7N3AP3iD6jsetfP+uft0Xt3ayx6doq2UzA+XIriUr05O4AH8q9jC5RjMZFTpQ93ufP43PcBgJOFap7y6I+yunfFULrX9OslYz31vGV6gyDNfnve/tUfEK6Zx/bR2SAgq0ak85zwAABj2rzrVPFer6vc+fdX85csSQrFRz1PHHP9DX0VHhStJ/vZpLyPlMRxth4q1Cm2/PQ+/PEf7U3gXQftkK6j9ovbclRBtK729Acf0rxXxJ+3Ff3du8Wl6SLGU9JQ4f6feH64r5WLM7A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Kw4x34/TrzXMFd31Poc/56ikB+YjH1x2/wAM0+WxtGnBdC/ea7qV+CLi/nZSMFA+xcEdMLgY61QRFHIAGe+MdvWlwQcdOuO3+c0cAHIzjqCP0/XpVWNfJAOSM4J9T649OaQqAOgPuPX6/pTumOM+/wCPY/lQD0PGevNUK43ueScc5Hf/ADmpI3aCeGaN2jkhdZY5ImKtG6kFXUjkMCAQRyCKZzx2wSOKRhkkY69s98cmoaTVmXFuLTi7NH6u/sefHWX44fCiCfV7mGXxXpEn2HVRGFUysBmO42A/KJEwTwBvEgAAXFe79K/L3/gn341m8NftEw6MZJBa+I9MntHhVsK0sI8+JyO5VFuFH/XQ1+oNfh+d4JYHGyhFe69V6M/dslxjxuChUlutH8h1FFFeEe6FFFFABRSDmq15qVrYAfabqG3B6GWQLn8zTSb0RLaW5aoqlaavZX7Fbe8t7hhyRFKrH9DVwmhprRgmnsLRRRSKCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAGnmvFPj9+zZpnxdtJdS09otM8UxxFYblwfJuCB8qTAAnHAG8Aso/vAba9ro610YfEVcLUVWk7NHHisLRxlJ0a8bpn5R+LPB+ueBNdn0XXtOm0vUI1BMcoysino8bj5ZFOCNy8A5BwQQMc46HIKnA4+6O/b+f8uK/U3x/8N/DvxN0b+zPEWmQ6hbq2+J2+WSB+zxuMMrdsgjIyDkEivkH4h/sO+J9AkkufB+ow+JbEAkWWoSLb3i8jCh8eW56kk+XwMc1+n5dxJQrpQxL5Jfg/wDL5n45m3CWJwsnUwi54duv/B+R84A5XhSMDA5PTrjPTHP8/egHHTj1JGDz6/pyD3+tbXiPwD4q8GtcDXfDOsaYkDbXnnsZTBnnOJkDRkY6ENiuaOp2IYgXtuCOCTKA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" />
									<br />
								</td> -->
								
							<td width="60%" align="center" valign="bottom" colspan="2">
									<table border="1" id="despatchTable">
										<tbody>
											<tr>
												<td style="width:105px;" align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Özelleştirme No</xsl:text>
												</span>
												</td>
												<td style="width:110px;" align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:CustomizationID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Senaryo</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:ProfileID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>İrsaliye Tipi</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:DespatchAdviceTypeCode">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>İrsaliye No</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:ID">
														<xsl:apply-templates></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>İrsaliye Tarihi</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:IssueDate">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>İrsaliye Zamanı</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:IssueTime">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Sevk Tarihi</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:IssueDate">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<tr style="height:13px; ">
												<td align="left">
												<span style="font-weight:bold; ">
												<xsl:text>Sevk Zamanı</xsl:text>
												</span>
												</td>
												<td align="left">
													<xsl:for-each select="n1:DespatchAdvice/cbc:IssueTime">
														<xsl:apply-templates select="."></xsl:apply-templates>
													</xsl:for-each>
												</td>
											</tr>
											<xsl:for-each select="n1:DespatchAdvice/cac:DespatchDocumentReference">
												<tr style="height:13px; ">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>İrsaliye No</xsl:text>
														</span>
														<xsl:text>&#160;</xsl:text>
													</td>
													<td align="left">
														<xsl:value-of select="cbc:ID"></xsl:value-of>
													</td>
												</tr>
												<tr style="height:13px; ">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>İrsaliye Tarihi</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="cbc:IssueDate">
															<xsl:apply-templates select="."></xsl:apply-templates>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:for-each>
											<xsl:if test="//n1:DespatchAdvice/cac:OrderReference">
												<tr style="height:13px">
													<td align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Sipariş No</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="n1:DespatchAdvice/cac:OrderReference/cbc:ID">
															<xsl:apply-templates></xsl:apply-templates>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:if>
											<xsl:if test="//n1:DespatchAdvice/cac:OrderReference/cbc:IssueDate">
												<tr style="height:13px">
													<td align="left">
														<span style="font-weight:bold; ">
														<xsl:text>Sipariş Tarihi</xsl:text>
														</span>
													</td>
													<td align="left">
														<xsl:for-each select="n1:DespatchAdvice/cac:OrderReference/cbc:IssueDate">
															<xsl:apply-templates select="."></xsl:apply-templates>
														</xsl:for-each>
													</td>
												</tr>
											</xsl:if>
											<xsl:for-each select="n1:DespatchAdvice/cac:TaxRepresentativeParty/cac:PartyIdentification/cbc:ID[@schemeID='ARACIKURUMVKN']"> 
												<tr>
													<td style="width:105px;" align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Aracı Kurum VKN</xsl:text>
														</span>
													</td>
													<td style="width:110px;" align="left">
														<xsl:value-of select="."></xsl:value-of>
													</td>
												</tr>
												<tr>
													<td style="width:105px;" align="left">
														<span style="font-weight:bold; ">
															<xsl:text>Aracı Kurum Unvan</xsl:text>
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
								<td align="left" valign="top" id="ettnTable">
									<span style="font-weight:bold; ">
										<xsl:text>ETTN:&#160;</xsl:text>
									</span>
									<xsl:for-each select="n1:DespatchAdvice/cbc:UUID">
										<xsl:apply-templates></xsl:apply-templates>
									</xsl:for-each>
								</td>
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
							<tr class="lineTableTr">
								<td class="lineTableTd" style="width:3%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>Sıra No</xsl:text>
									</span>
								</td>
								<td class="lineTableTd" style="width:10%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>Referans</xsl:text>
									</span>
								</td>
								<td class="lineTableTd" style="width:10%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>Barkod</xsl:text>
									</span>
								</td>							
								<td class="lineTableTd" style="width:30%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>Malzeme Açıklaması</xsl:text>
									</span>
								</td>									 	
								<td class="lineTableTd" style="width:10%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>SUT Kodu</xsl:text>
									</span>
								</td>
								<xsl:if test="//n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID = '2940035696'">
									<td class="lineTableTd" style="width:10%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Şartname/Malzeme Kodu</xsl:text>
										</span>
									</td>
								</xsl:if>									
								<td class="lineTableTd" style="width:7.4%" align="center">
									<span style="font-weight:bold;">
										<xsl:text>Miktar</xsl:text>
									</span>
								</td>
								<td id="lineTableTd" style="width:21%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Lot Bilgisi</xsl:text>
										</span>
							   </td>								
								<xsl:if test="//n1:DespatchAdvice/cbc:ProfileID='IHRACAT' or //n1:DespatchAdvice/cbc:ProfileID='OZELFATURA'">
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Teslim Şartı</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Eşya Kap Cinsi</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Kap No</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Kap Adet</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Teslim/Bedel Ödeme Yeri</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Gönderilme Şekli</xsl:text>
										</span>
									</td>									
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>GTİP</xsl:text>
										</span>
									</td>
									<td class="lineTableTd" style="width:10.6%" align="center">
										<span style="font-weight:bold;">
											<xsl:text>Byn. Edilen Kıymet Değeri</xsl:text>
										</span>
									</td>										
								</xsl:if>
							</tr>
							<xsl:if test="count(//n1:DespatchAdvice/cac:DespatchLine) &gt;= 14">
								<xsl:for-each select="//n1:DespatchAdvice/cac:DespatchLine">
									<xsl:apply-templates select="."></xsl:apply-templates>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="count(//n1:DespatchAdvice/cac:DespatchLine) &lt; 14">
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[1]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[1]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[2]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[2]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[3]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[3]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[4]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[4]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[5]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[5]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[6]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[6]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[7]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[7]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[8]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[8]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[9]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[9]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[10]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[10]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[11]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[11]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[12]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[12]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[13]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[13]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<!-- <xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[14]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[14]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose> -->
								<!-- <xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[15]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[15]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[16]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[16]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[17]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[17]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[18]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[18]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[19]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[19]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose>

								<xsl:choose>
									<xsl:when test="//n1:DespatchAdvice/cac:DespatchLine[20]">
										<xsl:apply-templates select="//n1:DespatchAdvice/cac:DespatchLine[20]"></xsl:apply-templates>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates select="//n1:DespatchAdvice"></xsl:apply-templates>
									</xsl:otherwise>
								</xsl:choose> -->

							</xsl:if>
						</tbody>
					</table>
				</xsl:for-each>
				<!--<table id="budgetContainerTable" width="800px">
					<tr align="right">
						<td/>
						<td class="lineTableBudgetTd" align="right" width="200px">
							<span style="font-weight:bold; ">
								<xsl:text>Mal Hizmet Toplam Tutarı</xsl:text>
							</span>
						</td>
						<td class="lineTableBudgetTd" style="width:81px; " align="right">
							<xsl:for-each select="n1:DespatchAdvice/cac:Shipment/cac:GoodsItem/cbc:ValueAmount">
								<xsl:call-template name="Curr_Type"/>
							</xsl:for-each>
						</td>
					</tr>


				</table>-->
				<br />
				<xsl:if test="//n1:DespatchAdvice/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[text()='İADE' or text()='IADE']">
					<table id="lineTable" width="800">
						<thead>
							<tr>
								<td align="left"><span style="font-weight:bold; " align="center">&#160;&#160;&#160;&#160;&#160;İadeye Konu Olan Faturalar</span></td>							
							</tr>
						</thead>					
						<tbody>
							<tr align="left" class="lineTableTr">							
								<td class="lineTableTd">
									<span style="font-weight:bold; " align="center">&#160;&#160;&#160;&#160;&#160;Fatura No</span>
								</td>
								<td class="lineTableTd"><span style="font-weight:bold; " align="center">&#160;&#160;&#160;&#160;&#160;Tarih</span></td>
							</tr>
							<xsl:for-each select="//n1:DespatchAdvice/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[text()='İADE' or text()='IADE']">
								<tr align="left" class="lineTableTr">
									<td class="lineTableTd">&#160;&#160;&#160;&#160;&#160;
										<xsl:value-of select="../cbc:ID"></xsl:value-of> 
									</td>
									<td class="lineTableTd">&#160;&#160;&#160;&#160;&#160;
										<xsl:for-each select="../cbc:IssueDate">
											<xsl:apply-templates select="."></xsl:apply-templates>
										</xsl:for-each> 
									</td>
								</tr>
							</xsl:for-each>
						</tbody>
					</table>
				</xsl:if>
				<br />
				<xsl:if test="//n1:DespatchAdvice/cac:BillingReference/cac:AdditionalDocumentReference/cbc:DocumentTypeCode='OKCBF'">
					<table border="1" id="lineTable" width="800">
						<thead>
							<tr>
								<th colspan="6">ÖKC Bilgileri</th>
							</tr>
						</thead>							
						<tbody>
							<tr id="okcbfHeadTr" style="font-weight:bold;">
								<td style="width:20%">
									<xsl:text>Fiş Numarası</xsl:text>
								</td>
								<td style="width:10%" align="center">
									<xsl:text>Fiş Tarihi</xsl:text>
								</td>
								<td style="width:10%" align="center">
									<xsl:text>Fiş Saati</xsl:text>
								</td>
								<td style="width:40%" align="center">
									<xsl:text>Fiş Tipi</xsl:text>
								</td>
								<td style="width:10%" align="center">
									<xsl:text>Z Rapor No</xsl:text>
								</td>
								<td style="width:10%" align="center">
									<xsl:text>ÖKC Seri No</xsl:text>
								</td>
							</tr>						
						</tbody>
						<xsl:for-each select="//n1:DespatchAdvice/cac:BillingReference/cac:AdditionalDocumentReference/cbc:DocumentTypeCode[text()='OKCBF']">
							<tr>
								<td style="width:20%">
									<xsl:value-of select="../cbc:ID"></xsl:value-of>
								</td>
								<td style="width:10%" align="center">
									<xsl:value-of select="../cbc:IssueDate"></xsl:value-of>
								</td>
								<td style="width:10%" align="center">
									<xsl:value-of select="substring(../cac:ValidityPeriod/cbc:StartTime,1,5)"></xsl:value-of>
								</td>
								<td style="width:40%" align="center">
									<xsl:choose>
										<xsl:when test="../cbc:DocumentDescription='AVANS'">
											<xsl:text>Ön Tahsilat(Avans) Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='YEMEK_FIS'">
											<xsl:text>Yemek Fişi/Kartı ile Yapılan Tahsilat Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='E-FATURA'">
											<xsl:text>E-Fatura Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='E-FATURA_IRSALIYE'">
											<xsl:text>İrsaliye Yerine Geçen E-Fatura Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='E-ARSIV'">
											<xsl:text>E-Arşiv Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='E-ARSIV_IRSALIYE'">
											<xsl:text>İrsaliye Yerine Geçen E-Arşiv Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='FATURA'">
											<xsl:text>Faturalı Satış Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='OTOPARK'">
											<xsl:text>Otopark Giriş Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='FATURA_TAHSILAT'">
											<xsl:text>Fatura Tahsilat Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:when test="../cbc:DocumentDescription='FATURA_TAHSILAT_KOMISYONLU'">
											<xsl:text>Komisyonlu Fatura Tahsilat Bilgi Fişi</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text> </xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</td>
								<td style="width:10%" align="center">
									<xsl:value-of select="../cac:Attachment/cac:ExternalReference/cbc:URI"></xsl:value-of>
								</td>
								<td style="width:10%" align="center">
									<xsl:value-of select="../cac:IssuerParty/cbc:EndpointID"></xsl:value-of>
								</td>
							</tr>													
						</xsl:for-each>
					</table>
					<br />
				</xsl:if>				
				<table id="notesTable" width="800" align="left">
					<tbody>
						<tr align="left">
							<td id="notesTableTd" height="100">
								<xsl:for-each select="//n1:DespatchAdvice/cac:TaxTotal/cac:TaxSubtotal">
									<xsl:if test="(cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode='0015' or ../../cbc:InvoiceTypeCode='OZELMATRAH') and cac:TaxCategory/cbc:TaxExemptionReason">									
										<b>&#160;&#160;&#160;&#160;&#160; Vergi İstisna Muafiyet Sebebi: </b>
										<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReasonCode"></xsl:value-of>
										<xsl:text>-</xsl:text>
										<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReason"></xsl:value-of>
										<br />
									</xsl:if>
									<xsl:if test="starts-with(cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode,'007') and cac:TaxCategory/cbc:TaxExemptionReason">									
										<b>&#160;&#160;&#160;&#160;&#160; ÖTV İstisna Muafiyet Sebebi: </b>
										<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReasonCode"></xsl:value-of>
										<xsl:text>-</xsl:text>
										<xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReason"></xsl:value-of>
										<br />
									</xsl:if>
								</xsl:for-each>
								<xsl:for-each select="//n1:DespatchAdvice/cac:WithholdingTaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme">
									<b>&#160;&#160;&#160;&#160;&#160; Tevkifat Sebebi: </b>
									<xsl:value-of select="cbc:TaxTypeCode"></xsl:value-of>
									<xsl:text>-</xsl:text>
									<xsl:value-of select="cbc:Name"></xsl:value-of>
									<br />
								</xsl:for-each>
								<xsl:for-each select="//n1:DespatchAdvice/cbc:Note">									
									<xsl:value-of select="."></xsl:value-of>	
									<br />
								</xsl:for-each>
								<xsl:if test="//n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID = '2940035696'">
									<br />
									<xsl:text>DMO satışına yönelik olarak düzenlenmiştir.</xsl:text><br />
									<xsl:text>Not: 173 Sıra No’lu Vergi Usul Kanunu Genel Tebliği’nin (C) bölümünün (f) bendine göre fatura düzenleme süresi</xsl:text><br />
									<xsl:text>Malzeme Muayene/Kabul ve Teslim/Tesellüm Tutanağı’nın düzenlendiği tarihten itibaren başlayacaktır.</xsl:text><br />
								</xsl:if>
								<xsl:for-each select="//n1:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cac:DriverPerson">									
									<br />
									<b> Taşıyıcı Firma : </b>
									<b> VKN : </b>
									<xsl:value-of select="./cbc:NationalityID"></xsl:value-of> &#160;
									<xsl:value-of select="./cbc:FirstName"></xsl:value-of> &#160;
									<xsl:value-of select="./cbc:FamilyName"></xsl:value-of>
									<br />
								</xsl:for-each>								
								<xsl:if test="//n1:DespatchAdvice/cac:PaymentMeans/cbc:InstructionNote">
									<b>&#160;&#160;&#160;&#160;&#160; Ödeme Notu: </b>
									<xsl:value-of select="//n1:DespatchAdvice/cac:PaymentMeans/cbc:InstructionNote"></xsl:value-of>
									<br />
								</xsl:if>
								<xsl:if test="//n1:DespatchAdvice/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:PaymentNote">
									<b>&#160;&#160;&#160;&#160;&#160; Hesap Açıklaması: </b>
									<xsl:value-of select="//n1:DespatchAdvice/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:PaymentNote"></xsl:value-of>
									<br />
								</xsl:if>
								<xsl:if test="//n1:DespatchAdvice/cac:PaymentTerms/cbc:Note">
									<b>&#160;&#160;&#160;&#160;&#160; Ödeme Koşulu: </b>
									<xsl:value-of select="//n1:DespatchAdvice/cac:PaymentTerms/cbc:Note"></xsl:value-of>
									<br />
								</xsl:if>
								<xsl:if test="//n1:DespatchAdvice/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='PARTYTYPE']='TAXFREE' and //n1:DespatchAdvice/cac:TaxRepresentativeParty/cac:PartyTaxScheme/cbc:ExemptionReasonCode">
									<br />
									<b>&#160;&#160;&#160;&#160;&#160; VAT OFF - NO CASH REFUND </b>
								</xsl:if>
							</td>
						</tr>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="//n1:DespatchAdvice/cac:DespatchLine">
		<tr class="lineTableTr">
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cbc:ID"></xsl:value-of>
			</td>
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cac:Item/cac:SellersItemIdentification/cbc:ID"></xsl:value-of>
			</td>
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cac:Item/cac:ManufacturersItemIdentification/cbc:ID"></xsl:value-of>
			</td>				
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cac:Item/cbc:Name"></xsl:value-of>
			</td>
			<td id="lineTableTd">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cac:Shipment/cac:GoodsItem/cac:InvoiceLine/cac:Item/cbc:ModelName"></xsl:value-of>
			</td>
			<xsl:if test="//n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID = '2940035696'">			
				<td class="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Shipment/cac:GoodsItem/cac:InvoiceLine/cac:Item/cbc:BrandName"></xsl:value-of>
				</td>
			</xsl:if>
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
				<xsl:value-of select="./cbc:DeliveredQuantity"></xsl:value-of>
				<xsl:if test="./cbc:DeliveredQuantity/@unitCode">
					<xsl:for-each select="./cbc:DeliveredQuantity">
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
			<td id="lineTableTd">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="./cac:Shipment/cac:GoodsItem/cac:InvoiceLine/cbc:Note"></xsl:value-of>
				</td>	
		</tr>
	</xsl:template>
	<xsl:template match="//cbc:IssueDate">
		<xsl:value-of select="substring(.,9,2)"></xsl:value-of>-<xsl:value-of select="substring(.,6,2)"></xsl:value-of>-<xsl:value-of select="substring(.,1,4)"></xsl:value-of>
	</xsl:template>
	<xsl:template match="//n1:DespatchAdvice">
		<tr class="lineTableTr">
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td class="lineTableTd">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>
			<xsl:if test="//n1:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID = '2940035696'">	
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
			</xsl:if>
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>			
			<td class="lineTableTd" align="right">
				<xsl:text>&#160;</xsl:text>
			</td>		
			<xsl:if test="//n1:DespatchAdvice/cbc:ProfileID='IHRACAT' or //n1:DespatchAdvice/cbc:ProfileID='OZELFATURA'">
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>
				<td class="lineTableTd" align="right">
					<xsl:text>&#160;</xsl:text>
				</td>				
			</xsl:if>			
		</tr>
	</xsl:template>
	<xsl:template name="Party_Title">
		<xsl:param name="PartyType"></xsl:param>
		<td style="width:469px; " align="left">
			<xsl:if test="cac:PartyName">
				<xsl:value-of select="cac:PartyName/cbc:Name"></xsl:value-of>
				<br />
			</xsl:if>
			<xsl:if test="cac:PartyLegalEntity">												
				<xsl:text>Vergi No:</xsl:text>
				<xsl:value-of select="cac:PartyLegalEntity/cbc:CompanyID"></xsl:value-of>
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
					<xsl:for-each select="cbc:NationalityID">
						<xsl:call-template name="Country">
							<xsl:with-param name="CountryType"><xsl:value-of select="."></xsl:value-of></xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
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
				<xsl:if test="$PartyType!='OTHER'">
					<br />
					<xsl:value-of select="cac:Country/cbc:Name"></xsl:value-of>
					<br />
				</xsl:if>
			</xsl:for-each>
		</td>
	</xsl:template>
	<xsl:template name="TransportMode">
		<xsl:param name="TransportModeType"></xsl:param>
		<xsl:choose>
			<xsl:when test="$TransportModeType=1">Denizyolu</xsl:when>
			<xsl:when test="$TransportModeType=2">Demiryolu</xsl:when>
			<xsl:when test="$TransportModeType=3">Karayolu</xsl:when>
			<xsl:when test="$TransportModeType=4">Havayolu</xsl:when>
			<xsl:when test="$TransportModeType=5">Posta</xsl:when>
			<xsl:when test="$TransportModeType=6">Çok araçlı</xsl:when>
			<xsl:when test="$TransportModeType=7">Sabit taşıma tesisleri</xsl:when>
			<xsl:when test="$TransportModeType=8">İç su taşımacılığı</xsl:when>			
			<xsl:otherwise><xsl:value-of select="$TransportModeType"></xsl:value-of></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	<xsl:template name="Packaging">
		<xsl:param name="PackagingType"></xsl:param>
		<xsl:choose>
			<xsl:when test="$PackagingType='1A'">Çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='1B'">Alüminyum bidon</xsl:when>
			<xsl:when test="$PackagingType='1D'">Kontraplak bidon</xsl:when>
			<xsl:when test="$PackagingType='1F'">Esnek ambalaj kutu</xsl:when>
			<xsl:when test="$PackagingType='1G'">Elyaflı silindir</xsl:when>
			<xsl:when test="$PackagingType='1W'">Ahşap silindir</xsl:when>
			<xsl:when test="$PackagingType='2C'">Ahşap varil</xsl:when>
			<xsl:when test="$PackagingType='3A'">Beş galonluk çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='3H'">Beş galonluk plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='43'">Torba, süper boy</xsl:when>
			<xsl:when test="$PackagingType='44'">Çoklu torba</xsl:when>
			<xsl:when test="$PackagingType='4A'">Çelik kutu</xsl:when>
			<xsl:when test="$PackagingType='4B'">Alüminyum kutu</xsl:when>
			<xsl:when test="$PackagingType='4C'">Doğal ahşap kutu</xsl:when>
			<xsl:when test="$PackagingType='4D'">Kontraplak kutu</xsl:when>
			<xsl:when test="$PackagingType='4F'">Yeniden üretilmiş ahşap kutu</xsl:when>
			<xsl:when test="$PackagingType='4G'">Elyaf tahta kutu</xsl:when>
			<xsl:when test="$PackagingType='4H'">Plastik kutu</xsl:when>
			<xsl:when test="$PackagingType='5H'">Plastik dokuma torba</xsl:when>
			<xsl:when test="$PackagingType='5L'">Kumaş torba</xsl:when>
			<xsl:when test="$PackagingType='5M'">Kağıt torba</xsl:when>
			<xsl:when test="$PackagingType='6H'">Kompozit ambalaj, plastik kap</xsl:when>
			<xsl:when test="$PackagingType='6P'">Kompozit ambalaj, cam kutu</xsl:when>
			<xsl:when test="$PackagingType='7A'">Araba kabı</xsl:when>
			<xsl:when test="$PackagingType='7B'">Ahşap kasa</xsl:when>
			<xsl:when test="$PackagingType='8A'">Ahşap palet</xsl:when>
			<xsl:when test="$PackagingType='8B'">Ahşap kasa</xsl:when>
			<xsl:when test="$PackagingType='8C'">Ahşap paketi</xsl:when>
			<xsl:when test="$PackagingType='AA'">Ortaboy sert plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='AB'">Elyaf kap</xsl:when>
			<xsl:when test="$PackagingType='AC'">Kağıt kap</xsl:when>
			<xsl:when test="$PackagingType='AD'">Ahşap kap</xsl:when>
			<xsl:when test="$PackagingType='AE'">Aerosol</xsl:when>
			<xsl:when test="$PackagingType='AF'">Palet, modüler, yaka 80cms * 60cms</xsl:when>
			<xsl:when test="$PackagingType='AG'">Sarılmış palet</xsl:when>
			<xsl:when test="$PackagingType='AH'">Palet, 100 cms * 110 cms</xsl:when>
			<xsl:when test="$PackagingType='AI'">Çift çeneli kepçe</xsl:when>
			<xsl:when test="$PackagingType='AJ'">Koni</xsl:when>
			<xsl:when test="$PackagingType='AL'">Top</xsl:when>
			<xsl:when test="$PackagingType='AM'">Korumasız ampul</xsl:when>
			<xsl:when test="$PackagingType='AP'">Korumalı ampül</xsl:when>
			<xsl:when test="$PackagingType='AT'">Püskürteç</xsl:when>
			<xsl:when test="$PackagingType='AV'">Kapsül</xsl:when>
			<xsl:when test="$PackagingType='B4'">Kemer</xsl:when>
			<xsl:when test="$PackagingType='BA'">Varil</xsl:when>
			<xsl:when test="$PackagingType='BB'">Bobin</xsl:when>
			<xsl:when test="$PackagingType='BC'">Şişe kasası/rafı</xsl:when>
			<xsl:when test="$PackagingType='BD'">Tahta</xsl:when>
			<xsl:when test="$PackagingType='BE'">Bohça</xsl:when>
			<xsl:when test="$PackagingType='BF'">Balon, korunmasız</xsl:when>
			<xsl:when test="$PackagingType='BG'">Torba</xsl:when>
			<xsl:when test="$PackagingType='BH'">Demet</xsl:when>
			<xsl:when test="$PackagingType='BI'">Çöp kutusu</xsl:when>
			<xsl:when test="$PackagingType='BJ'">Kova</xsl:when>
			<xsl:when test="$PackagingType='BK'">Sepet</xsl:when>
			<xsl:when test="$PackagingType='BL'">Sıkıştırılmış balya</xsl:when>
			<xsl:when test="$PackagingType='BM'">Kase</xsl:when>
			<xsl:when test="$PackagingType='BN'">Sıkıştırılmamış balya</xsl:when>
			<xsl:when test="$PackagingType='BO'">Şişe, korunmasız, silindirik</xsl:when>
			<xsl:when test="$PackagingType='BP'">Balon, korunmasız</xsl:when>
			<xsl:when test="$PackagingType='BQ'">Şişe, korunmuş, silindirik</xsl:when>
			<xsl:when test="$PackagingType='BR'">Çubuk</xsl:when>
			<xsl:when test="$PackagingType='BS'">Şişe, korunmasız, soğanbiçim</xsl:when>
			<xsl:when test="$PackagingType='BT'">Sürgü</xsl:when>
			<xsl:when test="$PackagingType='BU'">İzmarit</xsl:when>
			<xsl:when test="$PackagingType='BV'">Şişe, korunmuş, soğanbiçim</xsl:when>
			<xsl:when test="$PackagingType='BW'">Sıvılar için kutu</xsl:when>
			<xsl:when test="$PackagingType='BX'">Kutu</xsl:when>
			<xsl:when test="$PackagingType='BY'">Tahta, paket halinde/demet</xsl:when>
			<xsl:when test="$PackagingType='BZ'">Çıbuklar, paket halinde/demet</xsl:when>
			<xsl:when test="$PackagingType='CA'">Dikdörtgen teneke</xsl:when>
			<xsl:when test="$PackagingType='CB'">Bira kasası</xsl:when>
			<xsl:when test="$PackagingType='CC'">Yayık</xsl:when>
			<xsl:when test="$PackagingType='CD'">Teneke ibrik</xsl:when>
			<xsl:when test="$PackagingType='CE'">Balık sepeti</xsl:when>
			<xsl:when test="$PackagingType='CF'">Sandık</xsl:when>
			<xsl:when test="$PackagingType='CG'">Kafes</xsl:when>
			<xsl:when test="$PackagingType='CH'">Sandık</xsl:when>
			<xsl:when test="$PackagingType='CI'">Teneke kutu</xsl:when>
			<xsl:when test="$PackagingType='CJ'">Tabut</xsl:when>
			<xsl:when test="$PackagingType='CK'">Fıçı</xsl:when>
			<xsl:when test="$PackagingType='CL'">Bobin</xsl:when>
			<xsl:when test="$PackagingType='CM'">Kart</xsl:when>
			<xsl:when test="$PackagingType='CN'">Konteyner</xsl:when>
			<xsl:when test="$PackagingType='CO'">Damacana, korumasız</xsl:when>
			<xsl:when test="$PackagingType='CP'">Damacana, korumalı</xsl:when>
			<xsl:when test="$PackagingType='CQ'">Kartuş</xsl:when>
			<xsl:when test="$PackagingType='CR'">Kasa</xsl:when>
			<xsl:when test="$PackagingType='CS'">Kutu</xsl:when>
			<xsl:when test="$PackagingType='CT'">Karton kutu</xsl:when>
			<xsl:when test="$PackagingType='CU'">Fincan</xsl:when>
			<xsl:when test="$PackagingType='CV'">Kapak</xsl:when>
			<xsl:when test="$PackagingType='CW'">Rulo kafes</xsl:when>
			<xsl:when test="$PackagingType='CX'">Silindirik teneke</xsl:when>
			<xsl:when test="$PackagingType='CY'">Silindir</xsl:when>
			<xsl:when test="$PackagingType='CZ'">Tuval</xsl:when>
			<xsl:when test="$PackagingType='DA'">Kasa, çok tabakalı, plastik</xsl:when>
			<xsl:when test="$PackagingType='DB'">Kasa, çok tabakalı, ahşap</xsl:when>
			<xsl:when test="$PackagingType='DC'">Kasa, çok tabakalı, karton</xsl:when>
			<xsl:when test="$PackagingType='DI'">Demir varil</xsl:when>
			<xsl:when test="$PackagingType='DJ'">Damacana</xsl:when>
			<xsl:when test="$PackagingType='DK'">Karton kasa</xsl:when>
			<xsl:when test="$PackagingType='DL'">Plastik dökme kasa</xsl:when>
			<xsl:when test="$PackagingType='DM'">Ahşap dökme kasa</xsl:when>
			<xsl:when test="$PackagingType='DN'">Sebil/dağıtıcı</xsl:when>
			<xsl:when test="$PackagingType='DP'">Damacana, korumalı</xsl:when>
			<xsl:when test="$PackagingType='DR'">Bidon</xsl:when>
			<xsl:when test="$PackagingType='DS'">Üst kapaksız plastik tepsi, tek tabaka</xsl:when>
			<xsl:when test="$PackagingType='DT'">Üst kapaksız ahşap tepsi, tek tabaka</xsl:when>
			<xsl:when test="$PackagingType='DU'">Üst kapaksız polistiren tepsi, tek tabaka</xsl:when>
			<xsl:when test="$PackagingType='DV'">Üst kapaksız karton tepsi, tek tabaka</xsl:when>
			<xsl:when test="$PackagingType='DW'">Üst kapaksız plastik tepsi, çift tabaka</xsl:when>
			<xsl:when test="$PackagingType='DX'"></xsl:when>
			<xsl:when test="$PackagingType='DY'">Üst kapaksız karton tepsi, çift tabaka</xsl:when>
			<xsl:when test="$PackagingType='EC'">Plastik torba</xsl:when>
			<xsl:when test="$PackagingType='ED'">Kasa, palet tabanı ile</xsl:when>
			<xsl:when test="$PackagingType='EE'">Ahşap kasa, palet tabanı ile</xsl:when>
			<xsl:when test="$PackagingType='EF'">Karton kasa, palet tabanı ile</xsl:when>
			<xsl:when test="$PackagingType='EG'">Plastik kasa, palet tabanı ile</xsl:when>
			<xsl:when test="$PackagingType='EH'">Metal kasa, palet tabanı ile</xsl:when>
			<xsl:when test="$PackagingType='EI'">İzotermik kasa</xsl:when>
			<xsl:when test="$PackagingType='EN'">Zarf</xsl:when>
			<xsl:when test="$PackagingType='FB'">Plastik esnek torba</xsl:when>
			<xsl:when test="$PackagingType='FC'">Meyve kasası</xsl:when>
			<xsl:when test="$PackagingType='FD'">Çerçeveli kasa</xsl:when>
			<xsl:when test="$PackagingType='FE'">Plastik esnek depo</xsl:when>
			<xsl:when test="$PackagingType='FI'">Küçük fıçı</xsl:when>
			<xsl:when test="$PackagingType='FL'">Matara</xsl:when>
			<xsl:when test="$PackagingType='FO'">Küçük sandık</xsl:when>
			<xsl:when test="$PackagingType='FR'">Çerçeve</xsl:when>
			<xsl:when test="$PackagingType='FT'">Streçlenmiş yemek kabı</xsl:when>
			<xsl:when test="$PackagingType='FW'">Yanları üstü açık yük arabası</xsl:when>
			<xsl:when test="$PackagingType='FX'">Esnek torba</xsl:when>
			<xsl:when test="$PackagingType='GB'">Gaz şişesi</xsl:when>
			<xsl:when test="$PackagingType='GI'">Kiriş</xsl:when>
			<xsl:when test="$PackagingType='GL'">Konteyner, galon</xsl:when>
			<xsl:when test="$PackagingType='GR'">Cam kap</xsl:when>
			<xsl:when test="$PackagingType='GY'">Çul</xsl:when>
			<xsl:when test="$PackagingType='GZ'">Kiriş, demet/grup</xsl:when>
			<xsl:when test="$PackagingType='HA'">Saplı plastik sepet</xsl:when>
			<xsl:when test="$PackagingType='HB'">Saplı ahşap sepet</xsl:when>
			<xsl:when test="$PackagingType='HC'">Saplı karton sepet</xsl:when>
			<xsl:when test="$PackagingType='HG'">Büyük fıçı</xsl:when>
			<xsl:when test="$PackagingType='HN'">Askı</xsl:when>
			<xsl:when test="$PackagingType='HR'">Kapaklı sepet</xsl:when>
			<xsl:when test="$PackagingType='IA'">Ahşap sergi paketi</xsl:when>
			<xsl:when test="$PackagingType='IB'">Karton sergi paketi</xsl:when>
			<xsl:when test="$PackagingType='IC'">Plastik sergi paketi</xsl:when>
			<xsl:when test="$PackagingType='ID'">Metal sergi paketi</xsl:when>
			<xsl:when test="$PackagingType='IE'">Gösteri paketi</xsl:when>
			<xsl:when test="$PackagingType='IF'">Şeffaf oluklu paket</xsl:when>
			<xsl:when test="$PackagingType='IG'">Kağıt sarılı ambalaj</xsl:when>
			<xsl:when test="$PackagingType='IH'">Plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='IK'">Şişe delikli karton paket</xsl:when>
			<xsl:when test="$PackagingType='IL'">Tepsi, katı, kapaklı istiflenebilir</xsl:when>
			<xsl:when test="$PackagingType='IN'">Külçe</xsl:when>
			<xsl:when test="$PackagingType='IZ'">Paket/grop halde külçe</xsl:when>
			<xsl:when test="$PackagingType='JB'">Jumbo boy torba</xsl:when>
			<xsl:when test="$PackagingType='JC'">Beş galonluk dikdörtgen bidon</xsl:when>
			<xsl:when test="$PackagingType='JG'">Sürahi</xsl:when>
			<xsl:when test="$PackagingType='JR'">Kavanoz</xsl:when>
			<xsl:when test="$PackagingType='JY'">Beş galonluk silindir bidon</xsl:when>
			<xsl:when test="$PackagingType='KI'">Takım</xsl:when>
			<xsl:when test="$PackagingType='LE'">Bagaj</xsl:when>
			<xsl:when test="$PackagingType='LG'">Kütük</xsl:when>
			<xsl:when test="$PackagingType='LT'">Pay</xsl:when>
			<xsl:when test="$PackagingType='LU'">Kulp</xsl:when>
			<xsl:when test="$PackagingType='LV'">Liftvan</xsl:when>
			<xsl:when test="$PackagingType='LZ'">Paket/grup kütükler</xsl:when>
			<xsl:when test="$PackagingType='MA'">Metal kasa</xsl:when>
			<xsl:when test="$PackagingType='MB'">Çoklu çanta</xsl:when>
			<xsl:when test="$PackagingType='MC'">Süt kasasu</xsl:when>
			<xsl:when test="$PackagingType='ME'">Metal konteyner</xsl:when>
			<xsl:when test="$PackagingType='MR'">Metal kap</xsl:when>
			<xsl:when test="$PackagingType='MS'">Çok duvarlı çuval</xsl:when>
			<xsl:when test="$PackagingType='MT'">Mat</xsl:when>
			<xsl:when test="$PackagingType='MW'">Plastik sarılmış kap</xsl:when>
			<xsl:when test="$PackagingType='MX'">Kibrit kutusu</xsl:when>
			<xsl:when test="$PackagingType='NE'">Ambalajsız</xsl:when>
			<xsl:when test="$PackagingType='NF'">Ambalajsız, tek ünite</xsl:when>
			<xsl:when test="$PackagingType='NG'">Ambalajsız, çok ünite</xsl:when>
			<xsl:when test="$PackagingType='NS'">Yuva</xsl:when>
			<xsl:when test="$PackagingType='NT'">Ağ</xsl:when>
			<xsl:when test="$PackagingType='NU'">Plastik ağ tüp</xsl:when>
			<xsl:when test="$PackagingType='NV'">Kumaş ağ tüp</xsl:when>
			<xsl:when test="$PackagingType='OA'">Palet, CHEP 40x60 cm</xsl:when>
			<xsl:when test="$PackagingType='OB'">Palet, CHEP 80x120 cm</xsl:when>
			<xsl:when test="$PackagingType='OC'">Palet, CHEP 100x120 cm</xsl:when>
			<xsl:when test="$PackagingType='OD'">Avustralya standart paleti</xsl:when>
			<xsl:when test="$PackagingType='OE'">Palet,  110x100 cm</xsl:when>
			<xsl:when test="$PackagingType='OF'">Nakliye platformu, belirtilmemiş ağırlık ve bıyut</xsl:when>
			<xsl:when test="$PackagingType='OK'">Blok</xsl:when>
			<xsl:when test="$PackagingType='OT'">Sekiz kenar kutu</xsl:when>
			<xsl:when test="$PackagingType='OU'">Dış konteyner</xsl:when>
			<xsl:when test="$PackagingType='P2'">Tava</xsl:when>
			<xsl:when test="$PackagingType='PA'">Küçük paket</xsl:when>
			<xsl:when test="$PackagingType='PB'">Kombine açık uçlu kutu ve palet</xsl:when>
			<xsl:when test="$PackagingType='PC'">Parsel</xsl:when>
			<xsl:when test="$PackagingType='PD'">Palet, modüler 80 x 100 cm</xsl:when>
			<xsl:when test="$PackagingType='PE'">Palet, modüler 80 x 120 cm</xsl:when>
			<xsl:when test="$PackagingType='PF'">Kalem</xsl:when>
			<xsl:when test="$PackagingType='PG'">Plaka</xsl:when>
			<xsl:when test="$PackagingType='PH'">Sürahi</xsl:when>
			<xsl:when test="$PackagingType='PI'">Boru</xsl:when>
			<xsl:when test="$PackagingType='PJ'">Meyve sepeti</xsl:when>
			<xsl:when test="$PackagingType='PK'">Paket</xsl:when>
			<xsl:when test="$PackagingType='PL'">Gerdel</xsl:when>
			<xsl:when test="$PackagingType='PN'">Kalas</xsl:when>
			<xsl:when test="$PackagingType='PO'">Destek</xsl:when>
			<xsl:when test="$PackagingType='PP'">Parça</xsl:when>
			<xsl:when test="$PackagingType='PR'">Plastik kap</xsl:when>
			<xsl:when test="$PackagingType='PT'">Demlik</xsl:when>
			<xsl:when test="$PackagingType='PU'">Tepsi</xsl:when>
			<xsl:when test="$PackagingType='PV'">Paket/grup boru</xsl:when>
			<xsl:when test="$PackagingType='PX'">Palet</xsl:when>
			<xsl:when test="$PackagingType='PY'">Paket/grup tabak</xsl:when>
			<xsl:when test="$PackagingType='PZ'">Paket/grup kalas</xsl:when>
			<xsl:when test="$PackagingType='QA'">Üstü açılmaz çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='QB'">Üstü açılır çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='QC'">Üstü açılmaz alüminyum bidon</xsl:when>
			<xsl:when test="$PackagingType='QD'">Üstü açılır alüminyum bidon</xsl:when>
			<xsl:when test="$PackagingType='QF'">Üstü açılmaz plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='QG'">Üstü açılır plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='QH'">Ahşap tıkaçlı varil</xsl:when>
			<xsl:when test="$PackagingType='QJ'">Üstü açılır ahşap varil</xsl:when>
			<xsl:when test="$PackagingType='QK'">Üstü açılmaz beş galonluk çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='QL'">Üstü açılır beş galonluk çelik bidon</xsl:when>
			<xsl:when test="$PackagingType='QM'">Üstü açılmaz beş galonluk plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='QN'">Üstü açılır beş galonluk plastik bidon</xsl:when>
			<xsl:when test="$PackagingType='QP'">Doğal ahşap kutu</xsl:when>
			<xsl:when test="$PackagingType='QQ'">Emniyet duvarlı doğal ahşap kutu</xsl:when>
			<xsl:when test="$PackagingType='QR'">Genişletilmiş plastik kutu</xsl:when>
			<xsl:when test="$PackagingType='QS'">Yekpare plastik kutu</xsl:when>
			<xsl:when test="$PackagingType='RD'">Çubuk</xsl:when>
			<xsl:when test="$PackagingType='RG'">Halka</xsl:when>
			<xsl:when test="$PackagingType='RJ'">Raf, elbise askısı</xsl:when>
			<xsl:when test="$PackagingType='RK'">Raf</xsl:when>
			<xsl:when test="$PackagingType='RL'">Makara</xsl:when>
			<xsl:when test="$PackagingType='RO'">Rulo</xsl:when>
			<xsl:when test="$PackagingType='RZ'">Paket/grup çubuk</xsl:when>
			<xsl:when test="$PackagingType='SA'">Çuval</xsl:when>
			<xsl:when test="$PackagingType='SB'">Levha</xsl:when>
			<xsl:when test="$PackagingType='SC'">Sığ kasa</xsl:when>
			<xsl:when test="$PackagingType='SD'">İğ</xsl:when>
			<xsl:when test="$PackagingType='SE'">Deniz sandığı</xsl:when>
			<xsl:when test="$PackagingType='SH'">Kesecik</xsl:when>
			<xsl:when test="$PackagingType='SI'">Kızak</xsl:when>
			<xsl:when test="$PackagingType='SK'">İskelet kasa</xsl:when>
			<xsl:when test="$PackagingType='SL'">Taşıma paleti</xsl:when>
			<xsl:when test="$PackagingType='SM'">Sac</xsl:when>
			<xsl:when test="$PackagingType='SO'">Tel/kablo/iplik makarası</xsl:when>
			<xsl:when test="$PackagingType='SP'">Plastik levha</xsl:when>
			<xsl:when test="$PackagingType='SS'">Çelik kasa</xsl:when>
			<xsl:when test="$PackagingType='ST'">Yaprak</xsl:when>
			<xsl:when test="$PackagingType='SU'">Bavul</xsl:when>
			<xsl:when test="$PackagingType='SV'">Çelik zarf</xsl:when>
			<xsl:when test="$PackagingType='SW'">Vakumlu ambalaj</xsl:when>
			<xsl:when test="$PackagingType='SX'">Set</xsl:when>
			<xsl:when test="$PackagingType='SY'">Kılıf</xsl:when>
			<xsl:when test="$PackagingType='SZ'">Paket/grup yaprak</xsl:when>
			<xsl:when test="$PackagingType='T1'">Tablet</xsl:when>
			<xsl:when test="$PackagingType='TB'">Küvet</xsl:when>
			<xsl:when test="$PackagingType='TC'">Çay sandığı</xsl:when>
			<xsl:when test="$PackagingType='TD'">Sıkılabilir tüp</xsl:when>
			<xsl:when test="$PackagingType='TE'">Lastik</xsl:when>
			<xsl:when test="$PackagingType='TG'">Genel tank konteynerı</xsl:when>
			<xsl:when test="$PackagingType='TI'"></xsl:when>
			<xsl:when test="$PackagingType='TK'">Dikdörtgen tank</xsl:when>
			<xsl:when test="$PackagingType='TN'">Teneke</xsl:when>
			<xsl:when test="$PackagingType='TO'">Şarap fıçısı</xsl:when>
			<xsl:when test="$PackagingType='TR'">Gövde</xsl:when>
			<xsl:when test="$PackagingType='TS'">Bağ</xsl:when>
			<xsl:when test="$PackagingType='TU'">Tüp</xsl:when>
			<xsl:when test="$PackagingType='TV'">Enjektörlü tüp</xsl:when>
			<xsl:when test="$PackagingType='TY'">Silindirik tank</xsl:when>
			<xsl:when test="$PackagingType='TZ'">Paket/grup tüpler</xsl:when>
			<xsl:when test="$PackagingType='UN'">Birim</xsl:when>
			<xsl:when test="$PackagingType='VG'">Dökme gaz</xsl:when>
			<xsl:when test="$PackagingType='VI'">Küçük şişe</xsl:when>
			<xsl:when test="$PackagingType='VL'">Dökme sıvı</xsl:when>
			<xsl:when test="$PackagingType='VO'">Dökme katı</xsl:when>
			<xsl:when test="$PackagingType='VP'">Vakumlu</xsl:when>
			<xsl:when test="$PackagingType='VQ'">Dökme sıvılaştırılmış gaz</xsl:when>
			<xsl:when test="$PackagingType='VN'">Araç</xsl:when>
			<xsl:when test="$PackagingType='VR'">Dökme katı granül</xsl:when>
			<xsl:when test="$PackagingType='VS'">Dökme metal hurda</xsl:when>
			<xsl:when test="$PackagingType='VY'">Dökme ince parçacıklar</xsl:when>
			<xsl:when test="$PackagingType='WA'">Ortaboy dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WB'">Hasırlı şişe</xsl:when>
			<xsl:when test="$PackagingType='WC'">Ortaboy çelik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WD'">Ortaboy alüminyum dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WF'">Ortaboy metal dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WK'">Sıvılar için ortaboy çelik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WL'">Sıvılar için ortaboy alümünyum dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WM'">Sıvılar için ortaboy metal dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WN'">Ortaboy iç astarsız örme plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WR'">Ortaboy iç astarlı örme plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WS'">Ortaboy plastik film dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WT'">Ortaboy iç astarsız kumaş plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WU'">Ortaboy iç astarlı doğal ahşap dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WX'">Ortaboy iç astarlı kumaş dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WY'">Ortaboy iç astarlı kontraplak dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='WZ'">Ortaboy iç astarlı sunta dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='XA'">İç astarsız örme plastik torba</xsl:when>
			<xsl:when test="$PackagingType='XB'">Sızdırmaz örme plastik torba</xsl:when>
			<xsl:when test="$PackagingType='XC'">Su geçirmez örme plastik torba</xsl:when>
			<xsl:when test="$PackagingType='XD'">Plastik film torba</xsl:when>
			<xsl:when test="$PackagingType='XF'">İç astarsız kumaş torba</xsl:when>
			<xsl:when test="$PackagingType='XG'">Sızdırmaz kumaş torba</xsl:when>
			<xsl:when test="$PackagingType='XH'">Su geçirmez kumaş torba</xsl:when>
			<xsl:when test="$PackagingType='XJ'">Çok duvarlı kağıt torba</xsl:when>
			<xsl:when test="$PackagingType='XK'">Su geçirmez çok duvarlı kağıt torba</xsl:when>
			<xsl:when test="$PackagingType='YA'">Kompozit ambalaj, çelik bidon içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YB'">Kompozit ambalaj, çelik kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YC'">Kompozit ambalaj, alüminyum bidon içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YD'">Kompozit ambalaj, alüminyum kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YF'">Kompozit ambalaj, ahşap kutu içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YG'">Kompozit ambalaj, kontraplak bidon içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YH'">Kompozit ambalaj, kontraplak kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YJ'">Kompozit ambalaj, elyaf bidon içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YK'">Kompozit ambalaj, elyaf levha kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YL'">Kompozit ambalaj, plastik bidon içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YM'">Kompozit ambalaj, yekpare plastik kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YN'">Kompozit ambalaj, çelik bidon içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YP'">Kompozit ambalaj, elyaf levha kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YQ'">Kompozit ambalaj, alüminyum bidon içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YR'">Kompozit ambalaj, alüminyum kasa içindeki plastik kap</xsl:when>
			<xsl:when test="$PackagingType='YS'">Kompozit ambalaj, ahşap kasa içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YT'">Kompozit ambalaj, kontraplak bidon içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YV'">Kompozit ambalaj, hasır sepet içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YW'">Kompozit ambalaj, elyaf bidon içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YX'">Kompozit ambalaj, elyaf levha kasa içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YY'">Kompozit ambalaj, genişleyebilir plastik paket içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='YZ'">Kompozit ambalaj, yekpare plastik paket içindeki cam kap</xsl:when>
			<xsl:when test="$PackagingType='ZA'">Ortaboy çok duvarlı kağıt dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZB'">Büyük boy torba</xsl:when>
			<xsl:when test="$PackagingType='ZC'">Ortaboy çok duvarlı su geçirmez kağıt dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZL'">Ortaboy kompozit yekpare sert plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZM'">Ortaboy kompozit yekpare esnek plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZN'">Ortaboy kompozit sıkıştırılmış sert plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZP'">Ortaboy kompozit sıkıştırılmış esnek plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZQ'">Sıvılar için ortaboy kompozit sert plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZR'">Sıvılar için ortaboy kompozit esnek plastik dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZS'">Ortaboy kompozit dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZT'">Ortaboy elyaf levha dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZU'">Ortaboy esnek dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZW'">Ortaboy doğal ahşap dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZX'">Ortaboy kontraplak dolum konteynerı</xsl:when>
			<xsl:when test="$PackagingType='ZY'">Ortaboy sunta dolum konteynerı</xsl:when>
			<xsl:otherwise><xsl:value-of select="$PackagingType"></xsl:value-of></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	<xsl:template name="Country">
		<xsl:param name="CountryType"></xsl:param>
		<xsl:choose>
			<xsl:when test="$CountryType='AF'">Afganistan</xsl:when>
			<xsl:when test="$CountryType='DE'">Almanya</xsl:when>
			<xsl:when test="$CountryType='AD'">Andorra</xsl:when>
			<xsl:when test="$CountryType='AO'">Angola</xsl:when>
			<xsl:when test="$CountryType='AG'">Antigua ve Barbuda</xsl:when>
			<xsl:when test="$CountryType='AR'">Arjantin</xsl:when>
			<xsl:when test="$CountryType='AL'">Arnavutluk</xsl:when>
			<xsl:when test="$CountryType='AW'">Aruba</xsl:when>
			<xsl:when test="$CountryType='AU'">Avustralya</xsl:when>
			<xsl:when test="$CountryType='AT'">Avusturya</xsl:when>
			<xsl:when test="$CountryType='AZ'">Azerbaycan</xsl:when>
			<xsl:when test="$CountryType='BS'">Bahamalar</xsl:when>
			<xsl:when test="$CountryType='BH'">Bahreyn</xsl:when>
			<xsl:when test="$CountryType='BD'">Bangladeş</xsl:when>
			<xsl:when test="$CountryType='BB'">Barbados</xsl:when>
			<xsl:when test="$CountryType='EH'">Batı Sahra (MA)</xsl:when>
			<xsl:when test="$CountryType='BE'">Belçika</xsl:when>
			<xsl:when test="$CountryType='BZ'">Belize</xsl:when>
			<xsl:when test="$CountryType='BJ'">Benin</xsl:when>
			<xsl:when test="$CountryType='BM'">Bermuda</xsl:when>
			<xsl:when test="$CountryType='BY'">Beyaz Rusya</xsl:when>
			<xsl:when test="$CountryType='BT'">Bhutan</xsl:when>
			<xsl:when test="$CountryType='AE'">Birleşik Arap Emirlikleri</xsl:when>
			<xsl:when test="$CountryType='US'">Birleşik Devletler</xsl:when>
			<xsl:when test="$CountryType='GB'">Birleşik Krallık</xsl:when>
			<xsl:when test="$CountryType='BO'">Bolivya</xsl:when>
			<xsl:when test="$CountryType='BA'">Bosna-Hersek</xsl:when>
			<xsl:when test="$CountryType='BW'">Botsvana</xsl:when>
			<xsl:when test="$CountryType='BR'">Brezilya</xsl:when>
			<xsl:when test="$CountryType='BN'">Bruney</xsl:when>
			<xsl:when test="$CountryType='BG'">Bulgaristan</xsl:when>
			<xsl:when test="$CountryType='BF'">Burkina Faso</xsl:when>
			<xsl:when test="$CountryType='BI'">Burundi</xsl:when>
			<xsl:when test="$CountryType='TD'">Çad</xsl:when>
			<xsl:when test="$CountryType='KY'">Cayman Adaları</xsl:when>
			<xsl:when test="$CountryType='GI'">Cebelitarık (GB)</xsl:when>
			<xsl:when test="$CountryType='CZ'">Çek Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='DZ'">Cezayir</xsl:when>
			<xsl:when test="$CountryType='DJ'">Cibuti</xsl:when>
			<xsl:when test="$CountryType='CN'">Çin</xsl:when>
			<xsl:when test="$CountryType='DK'">Danimarka</xsl:when>
			<xsl:when test="$CountryType='CD'">Demokratik Kongo Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='TL'">Doğu Timor</xsl:when>
			<xsl:when test="$CountryType='DO'">Dominik Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='DM'">Dominika</xsl:when>
			<xsl:when test="$CountryType='EC'">Ekvador</xsl:when>
			<xsl:when test="$CountryType='GQ'">Ekvator Ginesi</xsl:when>
			<xsl:when test="$CountryType='SV'">El Salvador</xsl:when>
			<xsl:when test="$CountryType='ID'">Endonezya</xsl:when>
			<xsl:when test="$CountryType='ER'">Eritre</xsl:when>
			<xsl:when test="$CountryType='AM'">Ermenistan</xsl:when>
			<xsl:when test="$CountryType='MF'">Ermiş Martin (FR)</xsl:when>
			<xsl:when test="$CountryType='EE'">Estonya</xsl:when>
			<xsl:when test="$CountryType='ET'">Etiyopya</xsl:when>
			<xsl:when test="$CountryType='FK'">Falkland Adaları</xsl:when>
			<xsl:when test="$CountryType='FO'">Faroe Adaları (DK)</xsl:when>
			<xsl:when test="$CountryType='MA'">Fas</xsl:when>
			<xsl:when test="$CountryType='FJ'">Fiji</xsl:when>
			<xsl:when test="$CountryType='CI'">Fildişi Sahili</xsl:when>
			<xsl:when test="$CountryType='PH'">Filipinler</xsl:when>
			<xsl:when test="$CountryType='FI'">Finlandiya</xsl:when>
			<xsl:when test="$CountryType='FR'">Fransa</xsl:when>
			<xsl:when test="$CountryType='GF'">Fransız Guyanası (FR)</xsl:when>
			<xsl:when test="$CountryType='PF'">Fransız Polinezyası (FR)</xsl:when>
			<xsl:when test="$CountryType='GA'">Gabon</xsl:when>
			<xsl:when test="$CountryType='GM'">Gambiya</xsl:when>
			<xsl:when test="$CountryType='GH'">Gana</xsl:when>
			<xsl:when test="$CountryType='GN'">Gine</xsl:when>
			<xsl:when test="$CountryType='GW'">Gine Bissau</xsl:when>
			<xsl:when test="$CountryType='GD'">Grenada</xsl:when>
			<xsl:when test="$CountryType='GL'">Grönland (DK)</xsl:when>
			<xsl:when test="$CountryType='GP'">Guadeloupe (FR)</xsl:when>
			<xsl:when test="$CountryType='GT'">Guatemala</xsl:when>
			<xsl:when test="$CountryType='GG'">Guernsey (GB)</xsl:when>
			<xsl:when test="$CountryType='ZA'">Güney Afrika</xsl:when>
			<xsl:when test="$CountryType='KR'">Güney Kore</xsl:when>
			<xsl:when test="$CountryType='GE'">Gürcistan</xsl:when>
			<xsl:when test="$CountryType='GY'">Guyana</xsl:when>
			<xsl:when test="$CountryType='HT'">Haiti</xsl:when>
			<xsl:when test="$CountryType='IN'">Hindistan</xsl:when>
			<xsl:when test="$CountryType='HR'">Hırvatistan</xsl:when>
			<xsl:when test="$CountryType='NL'">Hollanda</xsl:when>
			<xsl:when test="$CountryType='HN'">Honduras</xsl:when>
			<xsl:when test="$CountryType='HK'">Hong Kong (CN)</xsl:when>
			<xsl:when test="$CountryType='VG'">İngiliz Virjin Adaları</xsl:when>
			<xsl:when test="$CountryType='IQ'">Irak</xsl:when>
			<xsl:when test="$CountryType='IR'">İran</xsl:when>
			<xsl:when test="$CountryType='IE'">İrlanda</xsl:when>
			<xsl:when test="$CountryType='ES'">İspanya</xsl:when>
			<xsl:when test="$CountryType='IL'">İsrail</xsl:when>
			<xsl:when test="$CountryType='SE'">İsveç</xsl:when>
			<xsl:when test="$CountryType='CH'">İsviçre</xsl:when>
			<xsl:when test="$CountryType='IT'">İtalya</xsl:when>
			<xsl:when test="$CountryType='IS'">İzlanda</xsl:when>
			<xsl:when test="$CountryType='JM'">Jamaika</xsl:when>
			<xsl:when test="$CountryType='JP'">Japonya</xsl:when>
			<xsl:when test="$CountryType='JE'">Jersey (GB)</xsl:when>
			<xsl:when test="$CountryType='KH'">Kamboçya</xsl:when>
			<xsl:when test="$CountryType='CM'">Kamerun</xsl:when>
			<xsl:when test="$CountryType='CA'">Kanada</xsl:when>
			<xsl:when test="$CountryType='ME'">Karadağ</xsl:when>
			<xsl:when test="$CountryType='QA'">Katar</xsl:when>
			<xsl:when test="$CountryType='KZ'">Kazakistan</xsl:when>
			<xsl:when test="$CountryType='KE'">Kenya</xsl:when>
			<xsl:when test="$CountryType='CY'">Kıbrıs</xsl:when>
			<xsl:when test="$CountryType='KG'">Kırgızistan</xsl:when>
			<xsl:when test="$CountryType='KI'">Kiribati</xsl:when>
			<xsl:when test="$CountryType='CO'">Kolombiya</xsl:when>
			<xsl:when test="$CountryType='KM'">Komorlar</xsl:when>
			<xsl:when test="$CountryType='CG'">Kongo Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='KV'">Kosova (RS)</xsl:when>
			<xsl:when test="$CountryType='CR'">Kosta Rika</xsl:when>
			<xsl:when test="$CountryType='CU'">Küba</xsl:when>
			<xsl:when test="$CountryType='KW'">Kuveyt</xsl:when>
			<xsl:when test="$CountryType='KP'">Kuzey Kore</xsl:when>
			<xsl:when test="$CountryType='LA'">Laos</xsl:when>
			<xsl:when test="$CountryType='LS'">Lesoto</xsl:when>
			<xsl:when test="$CountryType='LV'">Letonya</xsl:when>
			<xsl:when test="$CountryType='LR'">Liberya</xsl:when>
			<xsl:when test="$CountryType='LY'">Libya</xsl:when>
			<xsl:when test="$CountryType='LI'">Lihtenştayn</xsl:when>
			<xsl:when test="$CountryType='LT'">Litvanya</xsl:when>
			<xsl:when test="$CountryType='LB'">Lübnan</xsl:when>
			<xsl:when test="$CountryType='LU'">Lüksemburg</xsl:when>
			<xsl:when test="$CountryType='HU'">Macaristan</xsl:when>
			<xsl:when test="$CountryType='MG'">Madagaskar</xsl:when>
			<xsl:when test="$CountryType='MO'">Makao (CN)</xsl:when>
			<xsl:when test="$CountryType='MK'">Makedonya</xsl:when>
			<xsl:when test="$CountryType='MW'">Malavi</xsl:when>
			<xsl:when test="$CountryType='MV'">Maldivler</xsl:when>
			<xsl:when test="$CountryType='MY'">Malezya</xsl:when>
			<xsl:when test="$CountryType='ML'">Mali</xsl:when>
			<xsl:when test="$CountryType='MT'">Malta</xsl:when>
			<xsl:when test="$CountryType='IM'">Man Adası (GB)</xsl:when>
			<xsl:when test="$CountryType='MH'">Marshall Adaları</xsl:when>
			<xsl:when test="$CountryType='MQ'">Martinique (FR)</xsl:when>
			<xsl:when test="$CountryType='MU'">Mauritius</xsl:when>
			<xsl:when test="$CountryType='YT'">Mayotte (FR)</xsl:when>
			<xsl:when test="$CountryType='MX'">Meksika</xsl:when>
			<xsl:when test="$CountryType='FM'">Mikronezya</xsl:when>
			<xsl:when test="$CountryType='EG'">Mısır</xsl:when>
			<xsl:when test="$CountryType='MN'">Moğolistan</xsl:when>
			<xsl:when test="$CountryType='MD'">Moldova</xsl:when>
			<xsl:when test="$CountryType='MC'">Monako</xsl:when>
			<xsl:when test="$CountryType='MR'">Moritanya</xsl:when>
			<xsl:when test="$CountryType='MZ'">Mozambik</xsl:when>
			<xsl:when test="$CountryType='MM'">Myanmar</xsl:when>
			<xsl:when test="$CountryType='NA'">Namibya</xsl:when>
			<xsl:when test="$CountryType='NR'">Nauru</xsl:when>
			<xsl:when test="$CountryType='NP'">Nepal</xsl:when>
			<xsl:when test="$CountryType='NE'">Nijer</xsl:when>
			<xsl:when test="$CountryType='NG'">Nijerya</xsl:when>
			<xsl:when test="$CountryType='NI'">Nikaragua</xsl:when>
			<xsl:when test="$CountryType='NO'">Norveç</xsl:when>
			<xsl:when test="$CountryType='CF'">Orta Afrika Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='UZ'">Özbekistan</xsl:when>
			<xsl:when test="$CountryType='PK'">Pakistan</xsl:when>
			<xsl:when test="$CountryType='PW'">Palau</xsl:when>
			<xsl:when test="$CountryType='PA'">Panama</xsl:when>
			<xsl:when test="$CountryType='PG'">Papua Yeni Gine</xsl:when>
			<xsl:when test="$CountryType='PY'">Paraguay</xsl:when>
			<xsl:when test="$CountryType='PE'">Peru</xsl:when>
			<xsl:when test="$CountryType='PL'">Polonya</xsl:when>
			<xsl:when test="$CountryType='PT'">Portekiz</xsl:when>
			<xsl:when test="$CountryType='PR'">Porto Riko (US)</xsl:when>
			<xsl:when test="$CountryType='RE'">Réunion (FR)</xsl:when>
			<xsl:when test="$CountryType='RO'">Romanya</xsl:when>
			<xsl:when test="$CountryType='RW'">Ruanda</xsl:when>
			<xsl:when test="$CountryType='RU'">Rusya</xsl:when>
			<xsl:when test="$CountryType='BL'">Saint Barthélemy (FR)</xsl:when>
			<xsl:when test="$CountryType='KN'">Saint Kitts ve Nevis</xsl:when>
			<xsl:when test="$CountryType='LC'">Saint Lucia</xsl:when>
			<xsl:when test="$CountryType='PM'">Saint Pierre ve Miquelon (FR)</xsl:when>
			<xsl:when test="$CountryType='VC'">Saint Vincent ve Grenadinler</xsl:when>
			<xsl:when test="$CountryType='WS'">Samoa</xsl:when>
			<xsl:when test="$CountryType='SM'">San Marino</xsl:when>
			<xsl:when test="$CountryType='ST'">São Tomé ve Príncipe</xsl:when>
			<xsl:when test="$CountryType='SN'">Senegal</xsl:when>
			<xsl:when test="$CountryType='SC'">Seyşeller</xsl:when>
			<xsl:when test="$CountryType='SL'">Sierra Leone</xsl:when>
			<xsl:when test="$CountryType='CL'">Şili</xsl:when>
			<xsl:when test="$CountryType='SG'">Singapur</xsl:when>
			<xsl:when test="$CountryType='RS'">Sırbistan</xsl:when>
			<xsl:when test="$CountryType='SK'">Slovakya Cumhuriyeti</xsl:when>
			<xsl:when test="$CountryType='SI'">Slovenya</xsl:when>
			<xsl:when test="$CountryType='SB'">Solomon Adaları</xsl:when>
			<xsl:when test="$CountryType='SO'">Somali</xsl:when>
			<xsl:when test="$CountryType='SS'">South Sudan</xsl:when>
			<xsl:when test="$CountryType='SJ'">Spitsbergen (NO)</xsl:when>
			<xsl:when test="$CountryType='LK'">Sri Lanka</xsl:when>
			<xsl:when test="$CountryType='SD'">Sudan</xsl:when>
			<xsl:when test="$CountryType='SR'">Surinam</xsl:when>
			<xsl:when test="$CountryType='SY'">Suriye</xsl:when>
			<xsl:when test="$CountryType='SA'">Suudi Arabistan</xsl:when>
			<xsl:when test="$CountryType='SZ'">Svaziland</xsl:when>
			<xsl:when test="$CountryType='TJ'">Tacikistan</xsl:when>
			<xsl:when test="$CountryType='TZ'">Tanzanya</xsl:when>
			<xsl:when test="$CountryType='TH'">Tayland</xsl:when>
			<xsl:when test="$CountryType='TW'">Tayvan</xsl:when>
			<xsl:when test="$CountryType='TG'">Togo</xsl:when>
			<xsl:when test="$CountryType='TO'">Tonga</xsl:when>
			<xsl:when test="$CountryType='TT'">Trinidad ve Tobago</xsl:when>
			<xsl:when test="$CountryType='TN'">Tunus</xsl:when>
			<xsl:when test="$CountryType='TR'">Türkiye</xsl:when>
			<xsl:when test="$CountryType='TM'">Türkmenistan</xsl:when>
			<xsl:when test="$CountryType='TC'">Turks ve Caicos</xsl:when>
			<xsl:when test="$CountryType='TV'">Tuvalu</xsl:when>
			<xsl:when test="$CountryType='UG'">Uganda</xsl:when>
			<xsl:when test="$CountryType='UA'">Ukrayna</xsl:when>
			<xsl:when test="$CountryType='OM'">Umman</xsl:when>
			<xsl:when test="$CountryType='JO'">Ürdün</xsl:when>
			<xsl:when test="$CountryType='UY'">Uruguay</xsl:when>
			<xsl:when test="$CountryType='VU'">Vanuatu</xsl:when>
			<xsl:when test="$CountryType='VA'">Vatikan</xsl:when>
			<xsl:when test="$CountryType='VE'">Venezuela</xsl:when>
			<xsl:when test="$CountryType='VN'">Vietnam</xsl:when>
			<xsl:when test="$CountryType='WF'">Wallis ve Futuna (FR)</xsl:when>
			<xsl:when test="$CountryType='YE'">Yemen</xsl:when>
			<xsl:when test="$CountryType='NC'">Yeni Kaledonya (FR)</xsl:when>
			<xsl:when test="$CountryType='NZ'">Yeni Zelanda</xsl:when>
			<xsl:when test="$CountryType='CV'">Yeşil Burun Adaları</xsl:when>
			<xsl:when test="$CountryType='GR'">Yunanistan</xsl:when>
			<xsl:when test="$CountryType='ZM'">Zambiya</xsl:when>
			<xsl:when test="$CountryType='ZW'">Zimbabve</xsl:when>
			<xsl:otherwise><xsl:value-of select="$CountryType"></xsl:value-of></xsl:otherwise>
		</xsl:choose>
		
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
		<xsl:if test="$PartyType!='TAXFREE' and not(starts-with($PartyType, 'EXPORT'))">
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
