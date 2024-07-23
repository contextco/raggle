var e={};
/*! @license DOMPurify 3.1.6 | (c) Cure53 and other contributors | Released under the Apache license 2.0 and Mozilla Public License 2.0 | github.com/cure53/DOMPurify/blob/3.1.6/LICENSE */(function(t,n){e=n()})(0,(function(){const{entries:e,setPrototypeOf:t,isFrozen:n,getPrototypeOf:o,getOwnPropertyDescriptor:r}=Object;let{freeze:a,seal:i,create:l}=Object;let{apply:c,construct:s}=typeof Reflect!=="undefined"&&Reflect;a||(a=function freeze(e){return e});i||(i=function seal(e){return e});c||(c=function apply(e,t,n){return e.apply(t,n)});s||(s=function construct(e,t){return new e(...t)});const u=unapply(Array.prototype.forEach);const f=unapply(Array.prototype.pop);const d=unapply(Array.prototype.push);const m=unapply(String.prototype.toLowerCase);const p=unapply(String.prototype.toString);const h=unapply(String.prototype.match);const g=unapply(String.prototype.replace);const T=unapply(String.prototype.indexOf);const y=unapply(String.prototype.trim);const E=unapply(Object.prototype.hasOwnProperty);const S=unapply(RegExp.prototype.test);const _=unconstruct(TypeError);
/**
   * Creates a new function that calls the given function with a specified thisArg and arguments.
   *
   * @param {Function} func - The function to be wrapped and called.
   * @returns {Function} A new function that calls the given function with a specified thisArg and arguments.
   */function unapply(e){return function(t){for(var n=arguments.length,o=new Array(n>1?n-1:0),r=1;r<n;r++)o[r-1]=arguments[r];return c(e,t,o)}}
/**
   * Creates a new function that constructs an instance of the given constructor function with the provided arguments.
   *
   * @param {Function} func - The constructor function to be wrapped and called.
   * @returns {Function} A new function that constructs an instance of the given constructor function with the provided arguments.
   */function unconstruct(e){return function(){for(var t=arguments.length,n=new Array(t),o=0;o<t;o++)n[o]=arguments[o];return s(e,n)}}
/**
   * Add properties to a lookup table
   *
   * @param {Object} set - The set to which elements will be added.
   * @param {Array} array - The array containing elements to be added to the set.
   * @param {Function} transformCaseFunc - An optional function to transform the case of each element before adding to the set.
   * @returns {Object} The modified set with added elements.
   */function addToSet(e,o){let r=arguments.length>2&&arguments[2]!==void 0?arguments[2]:m;t&&t(e,null);let a=o.length;while(a--){let t=o[a];if(typeof t==="string"){const e=r(t);if(e!==t){n(o)||(o[a]=e);t=e}}e[t]=true}return e}
/**
   * Clean up an array to harden against CSPP
   *
   * @param {Array} array - The array to be cleaned.
   * @returns {Array} The cleaned version of the array
   */function cleanArray(e){for(let t=0;t<e.length;t++){const n=E(e,t);n||(e[t]=null)}return e}
/**
   * Shallow clone an object
   *
   * @param {Object} object - The object to be cloned.
   * @returns {Object} A new object that copies the original.
   */function clone(t){const n=l(null);for(const[o,r]of e(t)){const e=E(t,o);e&&(Array.isArray(r)?n[o]=cleanArray(r):r&&typeof r==="object"&&r.constructor===Object?n[o]=clone(r):n[o]=r)}return n}
/**
   * This method automatically checks if the prop is function or getter and behaves accordingly.
   *
   * @param {Object} object - The object to look up the getter function in its prototype chain.
   * @param {String} prop - The property name for which to find the getter function.
   * @returns {Function} The getter function found in the prototype chain or a fallback function.
   */function lookupGetter(e,t){while(e!==null){const n=r(e,t);if(n){if(n.get)return unapply(n.get);if(typeof n.value==="function")return unapply(n.value)}e=o(e)}function fallbackValue(){return null}return fallbackValue}const A=a(["a","abbr","acronym","address","area","article","aside","audio","b","bdi","bdo","big","blink","blockquote","body","br","button","canvas","caption","center","cite","code","col","colgroup","content","data","datalist","dd","decorator","del","details","dfn","dialog","dir","div","dl","dt","element","em","fieldset","figcaption","figure","font","footer","form","h1","h2","h3","h4","h5","h6","head","header","hgroup","hr","html","i","img","input","ins","kbd","label","legend","li","main","map","mark","marquee","menu","menuitem","meter","nav","nobr","ol","optgroup","option","output","p","picture","pre","progress","q","rp","rt","ruby","s","samp","section","select","shadow","small","source","spacer","span","strike","strong","style","sub","summary","sup","table","tbody","td","template","textarea","tfoot","th","thead","time","tr","track","tt","u","ul","var","video","wbr"]);const N=a(["svg","a","altglyph","altglyphdef","altglyphitem","animatecolor","animatemotion","animatetransform","circle","clippath","defs","desc","ellipse","filter","font","g","glyph","glyphref","hkern","image","line","lineargradient","marker","mask","metadata","mpath","path","pattern","polygon","polyline","radialgradient","rect","stop","style","switch","symbol","text","textpath","title","tref","tspan","view","vkern"]);const b=a(["feBlend","feColorMatrix","feComponentTransfer","feComposite","feConvolveMatrix","feDiffuseLighting","feDisplacementMap","feDistantLight","feDropShadow","feFlood","feFuncA","feFuncB","feFuncG","feFuncR","feGaussianBlur","feImage","feMerge","feMergeNode","feMorphology","feOffset","fePointLight","feSpecularLighting","feSpotLight","feTile","feTurbulence"]);const w=a(["animate","color-profile","cursor","discard","font-face","font-face-format","font-face-name","font-face-src","font-face-uri","foreignobject","hatch","hatchpath","mesh","meshgradient","meshpatch","meshrow","missing-glyph","script","set","solidcolor","unknown","use"]);const R=a(["math","menclose","merror","mfenced","mfrac","mglyph","mi","mlabeledtr","mmultiscripts","mn","mo","mover","mpadded","mphantom","mroot","mrow","ms","mspace","msqrt","mstyle","msub","msup","msubsup","mtable","mtd","mtext","mtr","munder","munderover","mprescripts"]);const D=a(["maction","maligngroup","malignmark","mlongdiv","mscarries","mscarry","msgroup","mstack","msline","msrow","semantics","annotation","annotation-xml","mprescripts","none"]);const C=a(["#text"]);const k=a(["accept","action","align","alt","autocapitalize","autocomplete","autopictureinpicture","autoplay","background","bgcolor","border","capture","cellpadding","cellspacing","checked","cite","class","clear","color","cols","colspan","controls","controlslist","coords","crossorigin","datetime","decoding","default","dir","disabled","disablepictureinpicture","disableremoteplayback","download","draggable","enctype","enterkeyhint","face","for","headers","height","hidden","high","href","hreflang","id","inputmode","integrity","ismap","kind","label","lang","list","loading","loop","low","max","maxlength","media","method","min","minlength","multiple","muted","name","nonce","noshade","novalidate","nowrap","open","optimum","pattern","placeholder","playsinline","popover","popovertarget","popovertargetaction","poster","preload","pubdate","radiogroup","readonly","rel","required","rev","reversed","role","rows","rowspan","spellcheck","scope","selected","shape","size","sizes","span","srclang","start","src","srcset","step","style","summary","tabindex","title","translate","type","usemap","valign","value","width","wrap","xmlns","slot"]);const v=a(["accent-height","accumulate","additive","alignment-baseline","ascent","attributename","attributetype","azimuth","basefrequency","baseline-shift","begin","bias","by","class","clip","clippathunits","clip-path","clip-rule","color","color-interpolation","color-interpolation-filters","color-profile","color-rendering","cx","cy","d","dx","dy","diffuseconstant","direction","display","divisor","dur","edgemode","elevation","end","fill","fill-opacity","fill-rule","filter","filterunits","flood-color","flood-opacity","font-family","font-size","font-size-adjust","font-stretch","font-style","font-variant","font-weight","fx","fy","g1","g2","glyph-name","glyphref","gradientunits","gradienttransform","height","href","id","image-rendering","in","in2","k","k1","k2","k3","k4","kerning","keypoints","keysplines","keytimes","lang","lengthadjust","letter-spacing","kernelmatrix","kernelunitlength","lighting-color","local","marker-end","marker-mid","marker-start","markerheight","markerunits","markerwidth","maskcontentunits","maskunits","max","mask","media","method","mode","min","name","numoctaves","offset","operator","opacity","order","orient","orientation","origin","overflow","paint-order","path","pathlength","patterncontentunits","patterntransform","patternunits","points","preservealpha","preserveaspectratio","primitiveunits","r","rx","ry","radius","refx","refy","repeatcount","repeatdur","restart","result","rotate","scale","seed","shape-rendering","specularconstant","specularexponent","spreadmethod","startoffset","stddeviation","stitchtiles","stop-color","stop-opacity","stroke-dasharray","stroke-dashoffset","stroke-linecap","stroke-linejoin","stroke-miterlimit","stroke-opacity","stroke","stroke-width","style","surfacescale","systemlanguage","tabindex","targetx","targety","transform","transform-origin","text-anchor","text-decoration","text-rendering","textlength","type","u1","u2","unicode","values","viewbox","visibility","version","vert-adv-y","vert-origin-x","vert-origin-y","width","word-spacing","wrap","writing-mode","xchannelselector","ychannelselector","x","x1","x2","xmlns","y","y1","y2","z","zoomandpan"]);const O=a(["accent","accentunder","align","bevelled","close","columnsalign","columnlines","columnspan","denomalign","depth","dir","display","displaystyle","encoding","fence","frame","height","href","id","largeop","length","linethickness","lspace","lquote","mathbackground","mathcolor","mathsize","mathvariant","maxsize","minsize","movablelimits","notation","numalign","open","rowalign","rowlines","rowspacing","rowspan","rspace","rquote","scriptlevel","scriptminsize","scriptsizemultiplier","selection","separator","separators","stretchy","subscriptshift","supscriptshift","symmetric","voffset","width","xmlns"]);const L=a(["xlink:href","xml:id","xlink:title","xml:space","xmlns:xlink"]);const x=i(/\{\{[\w\W]*|[\w\W]*\}\}/gm);const M=i(/<%[\w\W]*|[\w\W]*%>/gm);const I=i(/\${[\w\W]*}/gm);const U=i(/^data-[\-\w.\u00B7-\uFFFF]/);const P=i(/^aria-[\-\w]+$/);const F=i(/^(?:(?:(?:f|ht)tps?|mailto|tel|callto|sms|cid|xmpp):|[^a-z]|[a-z+.\-]+(?:[^a-z+.\-:]|$))/i);const H=i(/^(?:\w+script|data):/i);const z=i(/[\u0000-\u0020\u00A0\u1680\u180E\u2000-\u2029\u205F\u3000]/g);const G=i(/^html$/i);const B=i(/^[a-z][.\w]*(-[.\w]+)+$/i);var W=Object.freeze({__proto__:null,MUSTACHE_EXPR:x,ERB_EXPR:M,TMPLIT_EXPR:I,DATA_ATTR:U,ARIA_ATTR:P,IS_ALLOWED_URI:F,IS_SCRIPT_OR_DATA:H,ATTR_WHITESPACE:z,DOCTYPE_NAME:G,CUSTOM_ELEMENT:B});const Y={element:1,attribute:2,text:3,cdataSection:4,entityReference:5,entityNode:6,progressingInstruction:7,comment:8,document:9,documentType:10,documentFragment:11,notation:12};const j=function getGlobal(){return typeof window==="undefined"?null:window};
/**
   * Creates a no-op policy for internal use only.
   * Don't export this function outside this module!
   * @param {TrustedTypePolicyFactory} trustedTypes The policy factory.
   * @param {HTMLScriptElement} purifyHostElement The Script element used to load DOMPurify (to determine policy name suffix).
   * @return {TrustedTypePolicy} The policy created (or null, if Trusted Types
   * are not supported or creating the policy failed).
   */const X=function _createTrustedTypesPolicy(e,t){if(typeof e!=="object"||typeof e.createPolicy!=="function")return null;let n=null;const o="data-tt-policy-suffix";t&&t.hasAttribute(o)&&(n=t.getAttribute(o));const r="dompurify"+(n?"#"+n:"");try{return e.createPolicy(r,{createHTML(e){return e},createScriptURL(e){return e}})}catch(e){console.warn("TrustedTypes policy "+r+" could not be created.");return null}};function createDOMPurify(){let t=arguments.length>0&&arguments[0]!==void 0?arguments[0]:j();const DOMPurify=e=>createDOMPurify(e);DOMPurify.version="3.1.6";DOMPurify.removed=[];if(!t||!t.document||t.document.nodeType!==Y.document){DOMPurify.isSupported=false;return DOMPurify}let{document:n}=t;const o=n;const r=o.currentScript;const{DocumentFragment:i,HTMLTemplateElement:c,Node:s,Element:x,NodeFilter:M,NamedNodeMap:I=t.NamedNodeMap||t.MozNamedAttrMap,HTMLFormElement:U,DOMParser:P,trustedTypes:H}=t;const z=x.prototype;const B=lookupGetter(z,"cloneNode");const q=lookupGetter(z,"remove");const V=lookupGetter(z,"nextSibling");const $=lookupGetter(z,"childNodes");const K=lookupGetter(z,"parentNode");if(typeof c==="function"){const e=n.createElement("template");e.content&&e.content.ownerDocument&&(n=e.content.ownerDocument)}let Z;let J="";const{implementation:Q,createNodeIterator:ee,createDocumentFragment:te,getElementsByTagName:ne}=n;const{importNode:oe}=o;let re={};DOMPurify.isSupported=typeof e==="function"&&typeof K==="function"&&Q&&Q.createHTMLDocument!==void 0;const{MUSTACHE_EXPR:ae,ERB_EXPR:ie,TMPLIT_EXPR:le,DATA_ATTR:ce,ARIA_ATTR:se,IS_SCRIPT_OR_DATA:ue,ATTR_WHITESPACE:fe,CUSTOM_ELEMENT:de}=W;let{IS_ALLOWED_URI:me}=W;let pe=null;const he=addToSet({},[...A,...N,...b,...R,...C]);let ge=null;const Te=addToSet({},[...k,...v,...O,...L]);let ye=Object.seal(l(null,{tagNameCheck:{writable:true,configurable:false,enumerable:true,value:null},attributeNameCheck:{writable:true,configurable:false,enumerable:true,value:null},allowCustomizedBuiltInElements:{writable:true,configurable:false,enumerable:true,value:false}}));let Ee=null;let Se=null;let _e=true;let Ae=true;let Ne=false;let be=true;let we=false;let Re=true;let De=false;let Ce=false;let ke=false;let ve=false;let Oe=false;let Le=false;let xe=true;let Me=false;const Ie="user-content-";let Ue=true;let Pe=false;let Fe={};let He=null;const ze=addToSet({},["annotation-xml","audio","colgroup","desc","foreignobject","head","iframe","math","mi","mn","mo","ms","mtext","noembed","noframes","noscript","plaintext","script","style","svg","template","thead","title","video","xmp"]);let Ge=null;const Be=addToSet({},["audio","video","img","source","image","track"]);let We=null;const Ye=addToSet({},["alt","class","for","id","label","name","pattern","placeholder","role","summary","title","value","style","xmlns"]);const je="http://www.w3.org/1998/Math/MathML";const Xe="http://www.w3.org/2000/svg";const qe="http://www.w3.org/1999/xhtml";let Ve=qe;let $e=false;let Ke=null;const Ze=addToSet({},[je,Xe,qe],p);let Je=null;const Qe=["application/xhtml+xml","text/html"];const et="text/html";let tt=null;let nt=null;const ot=n.createElement("form");const rt=function isRegexOrFunction(e){return e instanceof RegExp||e instanceof Function};
/**
     * _parseConfig
     *
     * @param  {Object} cfg optional config literal
     */const at=function _parseConfig(){let e=arguments.length>0&&arguments[0]!==void 0?arguments[0]:{};if(!nt||nt!==e){e&&typeof e==="object"||(e={});e=clone(e);Je=Qe.indexOf(e.PARSER_MEDIA_TYPE)===-1?et:e.PARSER_MEDIA_TYPE;tt=Je==="application/xhtml+xml"?p:m;pe=E(e,"ALLOWED_TAGS")?addToSet({},e.ALLOWED_TAGS,tt):he;ge=E(e,"ALLOWED_ATTR")?addToSet({},e.ALLOWED_ATTR,tt):Te;Ke=E(e,"ALLOWED_NAMESPACES")?addToSet({},e.ALLOWED_NAMESPACES,p):Ze;We=E(e,"ADD_URI_SAFE_ATTR")?addToSet(clone(Ye),e.ADD_URI_SAFE_ATTR,tt):Ye;Ge=E(e,"ADD_DATA_URI_TAGS")?addToSet(clone(Be),e.ADD_DATA_URI_TAGS,tt):Be;He=E(e,"FORBID_CONTENTS")?addToSet({},e.FORBID_CONTENTS,tt):ze;Ee=E(e,"FORBID_TAGS")?addToSet({},e.FORBID_TAGS,tt):{};Se=E(e,"FORBID_ATTR")?addToSet({},e.FORBID_ATTR,tt):{};Fe=!!E(e,"USE_PROFILES")&&e.USE_PROFILES;_e=e.ALLOW_ARIA_ATTR!==false;Ae=e.ALLOW_DATA_ATTR!==false;Ne=e.ALLOW_UNKNOWN_PROTOCOLS||false;be=e.ALLOW_SELF_CLOSE_IN_ATTR!==false;we=e.SAFE_FOR_TEMPLATES||false;Re=e.SAFE_FOR_XML!==false;De=e.WHOLE_DOCUMENT||false;ve=e.RETURN_DOM||false;Oe=e.RETURN_DOM_FRAGMENT||false;Le=e.RETURN_TRUSTED_TYPE||false;ke=e.FORCE_BODY||false;xe=e.SANITIZE_DOM!==false;Me=e.SANITIZE_NAMED_PROPS||false;Ue=e.KEEP_CONTENT!==false;Pe=e.IN_PLACE||false;me=e.ALLOWED_URI_REGEXP||F;Ve=e.NAMESPACE||qe;ye=e.CUSTOM_ELEMENT_HANDLING||{};e.CUSTOM_ELEMENT_HANDLING&&rt(e.CUSTOM_ELEMENT_HANDLING.tagNameCheck)&&(ye.tagNameCheck=e.CUSTOM_ELEMENT_HANDLING.tagNameCheck);e.CUSTOM_ELEMENT_HANDLING&&rt(e.CUSTOM_ELEMENT_HANDLING.attributeNameCheck)&&(ye.attributeNameCheck=e.CUSTOM_ELEMENT_HANDLING.attributeNameCheck);e.CUSTOM_ELEMENT_HANDLING&&typeof e.CUSTOM_ELEMENT_HANDLING.allowCustomizedBuiltInElements==="boolean"&&(ye.allowCustomizedBuiltInElements=e.CUSTOM_ELEMENT_HANDLING.allowCustomizedBuiltInElements);we&&(Ae=false);Oe&&(ve=true);if(Fe){pe=addToSet({},C);ge=[];if(Fe.html===true){addToSet(pe,A);addToSet(ge,k)}if(Fe.svg===true){addToSet(pe,N);addToSet(ge,v);addToSet(ge,L)}if(Fe.svgFilters===true){addToSet(pe,b);addToSet(ge,v);addToSet(ge,L)}if(Fe.mathMl===true){addToSet(pe,R);addToSet(ge,O);addToSet(ge,L)}}if(e.ADD_TAGS){pe===he&&(pe=clone(pe));addToSet(pe,e.ADD_TAGS,tt)}if(e.ADD_ATTR){ge===Te&&(ge=clone(ge));addToSet(ge,e.ADD_ATTR,tt)}e.ADD_URI_SAFE_ATTR&&addToSet(We,e.ADD_URI_SAFE_ATTR,tt);if(e.FORBID_CONTENTS){He===ze&&(He=clone(He));addToSet(He,e.FORBID_CONTENTS,tt)}Ue&&(pe["#text"]=true);De&&addToSet(pe,["html","head","body"]);if(pe.table){addToSet(pe,["tbody"]);delete Ee.tbody}if(e.TRUSTED_TYPES_POLICY){if(typeof e.TRUSTED_TYPES_POLICY.createHTML!=="function")throw _('TRUSTED_TYPES_POLICY configuration option must provide a "createHTML" hook.');if(typeof e.TRUSTED_TYPES_POLICY.createScriptURL!=="function")throw _('TRUSTED_TYPES_POLICY configuration option must provide a "createScriptURL" hook.');Z=e.TRUSTED_TYPES_POLICY;J=Z.createHTML("")}else{Z===void 0&&(Z=X(H,r));Z!==null&&typeof J==="string"&&(J=Z.createHTML(""))}a&&a(e);nt=e}};const it=addToSet({},["mi","mo","mn","ms","mtext"]);const lt=addToSet({},["foreignobject","annotation-xml"]);const ct=addToSet({},["title","style","font","a","script"]);const st=addToSet({},[...N,...b,...w]);const ut=addToSet({},[...R,...D]);
/**
     * @param  {Element} element a DOM element whose namespace is being checked
     * @returns {boolean} Return false if the element has a
     *  namespace that a spec-compliant parser would never
     *  return. Return true otherwise.
     */const ft=function _checkValidNamespace(e){let t=K(e);t&&t.tagName||(t={namespaceURI:Ve,tagName:"template"});const n=m(e.tagName);const o=m(t.tagName);return!!Ke[e.namespaceURI]&&(e.namespaceURI===Xe?t.namespaceURI===qe?n==="svg":t.namespaceURI===je?n==="svg"&&(o==="annotation-xml"||it[o]):Boolean(st[n]):e.namespaceURI===je?t.namespaceURI===qe?n==="math":t.namespaceURI===Xe?n==="math"&&lt[o]:Boolean(ut[n]):e.namespaceURI===qe?!(t.namespaceURI===Xe&&!lt[o])&&(!(t.namespaceURI===je&&!it[o])&&(!ut[n]&&(ct[n]||!st[n]))):!(Je!=="application/xhtml+xml"||!Ke[e.namespaceURI]))};
/**
     * _forceRemove
     *
     * @param  {Node} node a DOM node
     */const dt=function _forceRemove(e){d(DOMPurify.removed,{element:e});try{K(e).removeChild(e)}catch(t){q(e)}};
/**
     * _removeAttribute
     *
     * @param  {String} name an Attribute name
     * @param  {Node} node a DOM node
     */const mt=function _removeAttribute(e,t){try{d(DOMPurify.removed,{attribute:t.getAttributeNode(e),from:t})}catch(e){d(DOMPurify.removed,{attribute:null,from:t})}t.removeAttribute(e);if(e==="is"&&!ge[e])if(ve||Oe)try{dt(t)}catch(e){}else try{t.setAttribute(e,"")}catch(e){}};
/**
     * _initDocument
     *
     * @param  {String} dirty a string of dirty markup
     * @return {Document} a DOM, filled with the dirty markup
     */const pt=function _initDocument(e){let t=null;let o=null;if(ke)e="<remove></remove>"+e;else{const t=h(e,/^[\r\n\t ]+/);o=t&&t[0]}Je==="application/xhtml+xml"&&Ve===qe&&(e='<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body>'+e+"</body></html>");const r=Z?Z.createHTML(e):e;if(Ve===qe)try{t=(new P).parseFromString(r,Je)}catch(e){}if(!t||!t.documentElement){t=Q.createDocument(Ve,"template",null);try{t.documentElement.innerHTML=$e?J:r}catch(e){}}const a=t.body||t.documentElement;e&&o&&a.insertBefore(n.createTextNode(o),a.childNodes[0]||null);return Ve===qe?ne.call(t,De?"html":"body")[0]:De?t.documentElement:a};
/**
     * Creates a NodeIterator object that you can use to traverse filtered lists of nodes or elements in a document.
     *
     * @param  {Node} root The root element or node to start traversing on.
     * @return {NodeIterator} The created NodeIterator
     */const ht=function _createNodeIterator(e){return ee.call(e.ownerDocument||e,e,M.SHOW_ELEMENT|M.SHOW_COMMENT|M.SHOW_TEXT|M.SHOW_PROCESSING_INSTRUCTION|M.SHOW_CDATA_SECTION,null)};
/**
     * _isClobbered
     *
     * @param  {Node} elm element to check for clobbering attacks
     * @return {Boolean} true if clobbered, false if safe
     */const gt=function _isClobbered(e){return e instanceof U&&(typeof e.nodeName!=="string"||typeof e.textContent!=="string"||typeof e.removeChild!=="function"||!(e.attributes instanceof I)||typeof e.removeAttribute!=="function"||typeof e.setAttribute!=="function"||typeof e.namespaceURI!=="string"||typeof e.insertBefore!=="function"||typeof e.hasChildNodes!=="function")};
/**
     * Checks whether the given object is a DOM node.
     *
     * @param  {Node} object object to check whether it's a DOM node
     * @return {Boolean} true is object is a DOM node
     */const Tt=function _isNode(e){return typeof s==="function"&&e instanceof s};
/**
     * _executeHook
     * Execute user configurable hooks
     *
     * @param  {String} entryPoint  Name of the hook's entry point
     * @param  {Node} currentNode node to work on with the hook
     * @param  {Object} data additional hook parameters
     */const yt=function _executeHook(e,t,n){re[e]&&u(re[e],(e=>{e.call(DOMPurify,t,n,nt)}))};
/**
     * _sanitizeElements
     *
     * @protect nodeName
     * @protect textContent
     * @protect removeChild
     *
     * @param   {Node} currentNode to check for permission to exist
     * @return  {Boolean} true if node was killed, false if left alive
     */const Et=function _sanitizeElements(e){let t=null;yt("beforeSanitizeElements",e,null);if(gt(e)){dt(e);return true}const n=tt(e.nodeName);yt("uponSanitizeElement",e,{tagName:n,allowedTags:pe});if(e.hasChildNodes()&&!Tt(e.firstElementChild)&&S(/<[/\w]/g,e.innerHTML)&&S(/<[/\w]/g,e.textContent)){dt(e);return true}if(e.nodeType===Y.progressingInstruction){dt(e);return true}if(Re&&e.nodeType===Y.comment&&S(/<[/\w]/g,e.data)){dt(e);return true}if(!pe[n]||Ee[n]){if(!Ee[n]&&_t(n)){if(ye.tagNameCheck instanceof RegExp&&S(ye.tagNameCheck,n))return false;if(ye.tagNameCheck instanceof Function&&ye.tagNameCheck(n))return false}if(Ue&&!He[n]){const t=K(e)||e.parentNode;const n=$(e)||e.childNodes;if(n&&t){const o=n.length;for(let r=o-1;r>=0;--r){const o=B(n[r],true);o.__removalCount=(e.__removalCount||0)+1;t.insertBefore(o,V(e))}}}dt(e);return true}if(e instanceof x&&!ft(e)){dt(e);return true}if((n==="noscript"||n==="noembed"||n==="noframes")&&S(/<\/no(script|embed|frames)/i,e.innerHTML)){dt(e);return true}if(we&&e.nodeType===Y.text){t=e.textContent;u([ae,ie,le],(e=>{t=g(t,e," ")}));if(e.textContent!==t){d(DOMPurify.removed,{element:e.cloneNode()});e.textContent=t}}yt("afterSanitizeElements",e,null);return false};
/**
     * _isValidAttribute
     *
     * @param  {string} lcTag Lowercase tag name of containing element.
     * @param  {string} lcName Lowercase attribute name.
     * @param  {string} value Attribute value.
     * @return {Boolean} Returns true if `value` is valid, otherwise false.
     */const St=function _isValidAttribute(e,t,o){if(xe&&(t==="id"||t==="name")&&(o in n||o in ot))return false;if(Ae&&!Se[t]&&S(ce,t));else if(_e&&S(se,t));else if(!ge[t]||Se[t]){if(!(_t(e)&&(ye.tagNameCheck instanceof RegExp&&S(ye.tagNameCheck,e)||ye.tagNameCheck instanceof Function&&ye.tagNameCheck(e))&&(ye.attributeNameCheck instanceof RegExp&&S(ye.attributeNameCheck,t)||ye.attributeNameCheck instanceof Function&&ye.attributeNameCheck(t))||t==="is"&&ye.allowCustomizedBuiltInElements&&(ye.tagNameCheck instanceof RegExp&&S(ye.tagNameCheck,o)||ye.tagNameCheck instanceof Function&&ye.tagNameCheck(o))))return false}else if(We[t]);else if(S(me,g(o,fe,"")));else if(t!=="src"&&t!=="xlink:href"&&t!=="href"||e==="script"||T(o,"data:")!==0||!Ge[e]){if(Ne&&!S(ue,g(o,fe,"")));else if(o)return false}else;return true};
/**
     * _isBasicCustomElement
     * checks if at least one dash is included in tagName, and it's not the first char
     * for more sophisticated checking see https://github.com/sindresorhus/validate-element-name
     *
     * @param {string} tagName name of the tag of the node to sanitize
     * @returns {boolean} Returns true if the tag name meets the basic criteria for a custom element, otherwise false.
     */const _t=function _isBasicCustomElement(e){return e!=="annotation-xml"&&h(e,de)};
/**
     * _sanitizeAttributes
     *
     * @protect attributes
     * @protect nodeName
     * @protect removeAttribute
     * @protect setAttribute
     *
     * @param  {Node} currentNode to sanitize
     */const At=function _sanitizeAttributes(e){yt("beforeSanitizeAttributes",e,null);const{attributes:t}=e;if(!t)return;const n={attrName:"",attrValue:"",keepAttr:true,allowedAttributes:ge};let o=t.length;while(o--){const r=t[o];const{name:a,namespaceURI:i,value:l}=r;const c=tt(a);let s=a==="value"?l:y(l);n.attrName=c;n.attrValue=s;n.keepAttr=true;n.forceKeepAttr=void 0;yt("uponSanitizeAttribute",e,n);s=n.attrValue;if(Re&&S(/((--!?|])>)|<\/(style|title)/i,s)){mt(a,e);continue}if(n.forceKeepAttr)continue;mt(a,e);if(!n.keepAttr)continue;if(!be&&S(/\/>/i,s)){mt(a,e);continue}we&&u([ae,ie,le],(e=>{s=g(s,e," ")}));const d=tt(e.nodeName);if(St(d,c,s)){if(Me&&(c==="id"||c==="name")){mt(a,e);s=Ie+s}if(Z&&typeof H==="object"&&typeof H.getAttributeType==="function")if(i);else switch(H.getAttributeType(d,c)){case"TrustedHTML":s=Z.createHTML(s);break;case"TrustedScriptURL":s=Z.createScriptURL(s);break}try{i?e.setAttributeNS(i,a,s):e.setAttribute(a,s);gt(e)?dt(e):f(DOMPurify.removed)}catch(e){}}}yt("afterSanitizeAttributes",e,null)};
/**
     * _sanitizeShadowDOM
     *
     * @param  {DocumentFragment} fragment to iterate over recursively
     */const Nt=function _sanitizeShadowDOM(e){let t=null;const n=ht(e);yt("beforeSanitizeShadowDOM",e,null);while(t=n.nextNode()){yt("uponSanitizeShadowNode",t,null);if(!Et(t)){t.content instanceof i&&_sanitizeShadowDOM(t.content);At(t)}}yt("afterSanitizeShadowDOM",e,null)};
/**
     * Sanitize
     * Public method providing core sanitation functionality
     *
     * @param {String|Node} dirty string or DOM node
     * @param {Object} cfg object
     */DOMPurify.sanitize=function(e){let t=arguments.length>1&&arguments[1]!==void 0?arguments[1]:{};let n=null;let r=null;let a=null;let l=null;$e=!e;$e&&(e="\x3c!--\x3e");if(typeof e!=="string"&&!Tt(e)){if(typeof e.toString!=="function")throw _("toString is not a function");e=e.toString();if(typeof e!=="string")throw _("dirty is not a string, aborting")}if(!DOMPurify.isSupported)return e;Ce||at(t);DOMPurify.removed=[];typeof e==="string"&&(Pe=false);if(Pe){if(e.nodeName){const t=tt(e.nodeName);if(!pe[t]||Ee[t])throw _("root node is forbidden and cannot be sanitized in-place")}}else if(e instanceof s){n=pt("\x3c!----\x3e");r=n.ownerDocument.importNode(e,true);r.nodeType===Y.element&&r.nodeName==="BODY"||r.nodeName==="HTML"?n=r:n.appendChild(r)}else{if(!ve&&!we&&!De&&e.indexOf("<")===-1)return Z&&Le?Z.createHTML(e):e;n=pt(e);if(!n)return ve?null:Le?J:""}n&&ke&&dt(n.firstChild);const c=ht(Pe?e:n);while(a=c.nextNode())if(!Et(a)){a.content instanceof i&&Nt(a.content);At(a)}if(Pe)return e;if(ve){if(Oe){l=te.call(n.ownerDocument);while(n.firstChild)l.appendChild(n.firstChild)}else l=n;(ge.shadowroot||ge.shadowrootmode)&&(l=oe.call(o,l,true));return l}let f=De?n.outerHTML:n.innerHTML;De&&pe["!doctype"]&&n.ownerDocument&&n.ownerDocument.doctype&&n.ownerDocument.doctype.name&&S(G,n.ownerDocument.doctype.name)&&(f="<!DOCTYPE "+n.ownerDocument.doctype.name+">\n"+f);we&&u([ae,ie,le],(e=>{f=g(f,e," ")}));return Z&&Le?Z.createHTML(f):f};
/**
     * Public method to set the configuration once
     * setConfig
     *
     * @param {Object} cfg configuration object
     */DOMPurify.setConfig=function(){let e=arguments.length>0&&arguments[0]!==void 0?arguments[0]:{};at(e);Ce=true};DOMPurify.clearConfig=function(){nt=null;Ce=false};
/**
     * Public method to check if an attribute value is valid.
     * Uses last set config, if any. Otherwise, uses config defaults.
     * isValidAttribute
     *
     * @param  {String} tag Tag name of containing element.
     * @param  {String} attr Attribute name.
     * @param  {String} value Attribute value.
     * @return {Boolean} Returns true if `value` is valid. Otherwise, returns false.
     */DOMPurify.isValidAttribute=function(e,t,n){nt||at({});const o=tt(e);const r=tt(t);return St(o,r,n)};
/**
     * AddHook
     * Public method to add DOMPurify hooks
     *
     * @param {String} entryPoint entry point for the hook to add
     * @param {Function} hookFunction function to execute
     */DOMPurify.addHook=function(e,t){if(typeof t==="function"){re[e]=re[e]||[];d(re[e],t)}};
/**
     * RemoveHook
     * Public method to remove a DOMPurify hook at a given entryPoint
     * (pops it from the stack of hooks if more are present)
     *
     * @param {String} entryPoint entry point for the hook to remove
     * @return {Function} removed(popped) hook
     */DOMPurify.removeHook=function(e){if(re[e])return f(re[e])};
/**
     * RemoveHooks
     * Public method to remove all DOMPurify hooks at a given entryPoint
     *
     * @param  {String} entryPoint entry point for the hooks to remove
     */DOMPurify.removeHooks=function(e){re[e]&&(re[e]=[])};DOMPurify.removeAllHooks=function(){re={}};return DOMPurify}var q=createDOMPurify();return q}));var t=e;export{t as default};

