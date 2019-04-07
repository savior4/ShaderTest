//遮罩纹理
Shader "Unity Shaders Book/Chpter 7/Mask TexTure"
{
    Properties{
        _Color ("Color Tint", Color)=(1,1,1,1)
        _MainTex ("Main Tex",2D)="white"{}
        _BumpMap ("Normal Map",2D)="bump"{}
        _BumpScale("Bumo Scale",float)=1.0
        _SpecularMask("Specular Mask",2D)="white"{}
        _SpecularScale("Specular Scale",float)=1.0
        _Specular ("Speclar",Color)=(1,1,1,1)
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
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{

            };
            ENDCG
        }
    }
}