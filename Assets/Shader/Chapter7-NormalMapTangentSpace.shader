// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//切线空间下的法线纹理
Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space"{
    Properties{
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex ("Main Tex",2D)="white"{}
        _BumpMap("Normal Map",2D)="bump"{}//法线纹理
        _BumpScale("Bump Scale",float)=1.0
        _Specular ("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
    SubShader{
        Pass{
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;//纹理的缩放和偏移属性
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;//切线方向
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv.xy=v.texcoord.xy * _MainTex_ST.xy +_MainTex_ST.zw;
                o.uv.zw=v.texcoord.xy * _BumpMap_ST.xy +_BumpMap_ST.zw;

                //计算副切线   与切线与法线垂直，tangent.w决定了副切线的方向
                float3 binormal= cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;

                //计算从模型空间到切线空间的变换矩阵 rotation  （把模型空间下的切线防线，副切线方向和法线方向按行排列）
                float3x3 rotation=float3x3 (v.tangent.xyz,binormal,v.normal);  //内置宏 TANGENT_SPACE_ROTATION
                //将模型空间下的光照和视角方向转变为切线空间下
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i): SV_TARGET{
                fixed3 tangentLightDir=normalize(i.lightDir);
                fixed3 tangentViewDir=normalize(i.viewDir);

                //法线贴图采样
                fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
                fixed3 tangentNormal;

                tangentNormal=UnpackNormal(packedNormal);
                tangentNormal.xy*=_BumpScale;
                tangentNormal.z=sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

                fixed3 diffuse= _LightColor0.rgb *albedo *max(0,dot(tangentNormal,tangentLightDir));
                fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
                fixed3 specular=_LightColor0.rgb * _Specular.rgb *pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
                return fixed4(ambient+diffuse+specular,1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}