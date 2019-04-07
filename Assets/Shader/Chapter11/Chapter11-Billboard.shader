// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/Billboard"{
    Properties{
        _MainTex("Main Tex",2D)="white"{}
        _Color("Color Tint",Color)=(1,1,1,1)
        _VerticalBillboarding("约束垂直方向的程度",Range(0,1))=1//约束垂直方向的程度  用于调整是固定法线还是固定指向上的方向
    }

    SubShader{
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

        pass{
            Tags{"LightMode"="ForwardBase"}

            ZWrite off 
            Blend SrcAlpha OneMinusSrcAlpha
            Cull off 

            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _VerticalBillboarding;

            struct a2f{
                float4 vertex :POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2f v){
                v2f o;
                //假设物体空间的中心是固定的
                float3 center = float3(0,0,0);
                float3 viewer = mul(unity_WorldToObject , float4(_WorldSpaceCameraPos , 1));

                //计算3个正交矢量
                float3 normalDir = viewer - center;
                normalDir.y = normalDir.y* _VerticalBillboarding;
                normalDir = normalize(normalDir);
                ///得到粗略的向上的方向
                float3 upDir=abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
                //得到向右的方向
                float3 rightDir=normalize(cross(upDir,normalDir));

                upDir = normalize(cross(normalDir,rightDir));
                float3 centerOffset = v.vertex.xyz - center;
                float3 localPos=center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;

                o.pos = UnityObjectToClipPos(float4(localPos,1));
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                fixed4 c =tex2D(_MainTex,i.uv);
                c.rgb *= _Color.rgb;
                return c;
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}