//模拟河流效果
Shader "Unity Shaders Book/Chapter 7/Water"{
    properties{
        _MainTex ("Main Tex", 2D) ="white"{}
        _Color("Color Tint",Color)=(1,1,1,1)
        _Magnitude("波动幅度",float)=1//Distortion Magnitude 用于控制水流波动的幅度
        _Frequency ("波动频率",float )=1//Distortion Frequency 用于控制波动频率
        _InvWaveLength("波长",float)=10//Distortion Inverse Wave Length 用于控制波长的倒数  值越大，波长越小
        _Speed("速度",float )=0.5
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
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v{
                float4 vertex : POSITION;
                float4 texcoord :TEXCOORD0;
            };

            struct v2f{
                float4 pos :SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v){
                v2f o;
                float4 offset;
                offset.yzw=float3(0.0,0.0,0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;

                o.pos = UnityObjectToClipPos(v.vertex + offset);

                o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
                o.uv +=  float2(0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                fixed4 c= tex2D(_MainTex,i.uv);
                c.rgb *= _Color;
                return c;
            }
            ENDCG
        }
    }
}