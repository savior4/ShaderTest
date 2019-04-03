
Shader "Unity Shaders Book/Chapter 6/Specular Verterx"{
	Properties{
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8,256))=20
	}
	SubShader{
		Pass{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			struct a2v{
				float4 vertex:POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 color:COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				//计算 环境光
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

				//计算漫反射 Clight * Mdiffuse * max(0,n·i)
				fixed3 n=normalize(mul((float3x3)unity_ObjectToWorld,v.normal));//计算世界空间下单位法线

				fixed3 i=normalize(_WorldSpaceLightPos0.xyz); //计算光源方向单位向量
				//套用漫反射公式
				fixed3 diffuse=_LightColor0.rgb * _Diffuse.rgb * saturate(dot(n,i));

				//计算高光反射  Clight * Mspecular * pow(max(dot(v,r)),Mgloss)
				//r=Normalize(I,n)
				fixed3 r=normalize(reflect(-i,n));
				//向量方向朝向视野(摄像机)
				fixed3 normalV=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);

				//套用高光反射公式
				fixed3 specular=_LightColor0 * _Specular.rgb *pow(saturate(dot(normalV,r)),_Gloss);

				o.color = ambient + diffuse + specular;
				return o;

			}

			fixed4 frag(v2f i) : SV_TARGET{
				return fixed4(i.color,1.0);
			}
			 
			ENDCG
		}
	}
	Fallback "Specular"
}