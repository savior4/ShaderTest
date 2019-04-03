// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

//使用标准光照模型中的逐顶点漫反射光照
Shader"Unity Shaders Book/Chapter 6/Diffuse Vertex"{
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
				fixed3 color : COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				//将模型空间的定点坐标转换到裁剪空间
				o.pos=UnityObjectToClipPos(v.vertex);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal=normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse =_LightColor0.rgb * _Diffuse.rgb *saturate(dot(worldNormal,worldLight));

				o.color=ambient+diffuse;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}