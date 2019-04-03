//半兰伯特光照模型
Shader"Unity Shaders Book/Chapter 6/HalfLambert"{
	Properties{
		_Diffuse("Diffuse",Color)=(1,1,1,1)
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag 

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			//顶点着色器的输入结构体
			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			//顶点着色器的输出，片元着色器的输入
			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};
			//定点着色器
			v2f vert(a2v v){
				v2f o;
				//将模型空间的定点坐标转换到裁剪空间
				o.pos=UnityObjectToClipPos(v.vertex);
				o.worldNormal=mul(v.normal,(float3x3)unity_WorldToObject);
				return o;
			}
			//片元着色器
			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal= normalize(i.worldNormal);
				fixed3 worldLightDir= normalize(_WorldSpaceLightPos0.xyz);

				fixed3 halfLambert= dot(worldNormal,worldLightDir)*0.5+0.5;
				fixed3 diffuse= _LightColor0.rgb * _Diffuse.rgb *halfLambert;
				fixed3 color=ambient + diffuse;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}