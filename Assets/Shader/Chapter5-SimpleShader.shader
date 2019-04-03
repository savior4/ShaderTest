// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/Simple Shader"{
	Properties{
		_color("Color Tint",Color)=(1.0,1.0,1.0,1.0)
	}
	SubShader{
		Pass{
			CGPROGRAM
		#include "UnityCG.cginc"
		#pragma vertex vert
		#pragma fragment frag

		fixed4 _color;

		//使用一个结构体来定义定点着色器的输入
		struct a2v{
			//POSITION语义告诉Unity，用模型空间的定点坐标填充vertex变量
			float4 vertex:POSITION;
			//NORMAL语义告诉Unity，用模型空间的法线方向填充normal变量
			float3 normal :NORMAL;
			//TEXCOORD0语义告诉Unity，用模型的第一套纹理坐标填充texcoord变量
			float4 texcoord :TEXCOORD0;
		};

		//使用一个结构体来定义顶点着色器的输出
		struct v2f{
			//SV_POSITION语义告诉Unity，pos里面包含了定点在裁剪空间中的位置信息
			float4 pos:SV_POSITION;
			//COLOR0语义可以用于存储颜色信息
			fixed3 color :COLOR0;
		};

		//顶点着色器
		v2f vert(a2v v){
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			//v.normal包含了定点的法线方向，其分量范围在[-1.0,10]
			//下面的代码把分量范围映射到了[0.0,1.0]
			//存储到o.color中传递给片元着色器
			o.color =v.normal*0.5+fixed3(0.5,0.5,0.5);
			return o;
		}
		
		//片元着色器
		fixed4 frag(v2f i) : SV_TARGET{
			fixed3 c=i.color;
			//使用_color属性来控制输出颜色
			c*=_color.rgb;
			//将插值后的i.color显示到屏幕上
			return fixed4(c,1.0);
		}

		ENDCG
		}
	}
}