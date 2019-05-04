Shader "Unity Shaders Book/Chapter 9/Shadow"
{
    Properties{
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
    }
   SubShader{
       Tags{"RenderType"="Opaque"}
       //base pass
       pass{
           Tags{"LightMode"="ForwardBase"}

           CGPROGRAM

           #pragma vertex vert 
           #pragma fragment frag
           #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal  : NORMAL;
            };

            struct v2f{
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)//声明一个用于对阴影纹理采样的坐标
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                TRANSFER_SHADOW(o);//用于在定点着色器中计算上一步中声明的阴影纹理坐标
                return o;
            }

            fixed4 frag(v2f i):  SV_TARGET{
                fixed shadow=SHADOW_ATTENUATION(i);
                fixed3 worldNormal= normalize(i.worldNormal);
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);

                fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse=_LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir=normalize(worldLightDir+viewDir);
                fixed3 specular=_LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed atten=1.0;

                return fixed4(shadow*(ambient+(diffuse + specular)*atten),1.0);//接收阴影
                //return fixed4((ambient+(diffuse + specular)*atten),1.0);//不接收阴影
            }
           ENDCG
       }
        //pass for other pixel lights
       pass{
           Tags{"LightMode"="ForwardAdd"}

           Blend One One

           CGPROGRAM
           #pragma multi_compile_fwdadd
           #pragma vertex vert
           #pragma fragment frag 

           #include "Lighting.cginc"
           #include "AutoLight.cginc"

           fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal  : NORMAL;
            };

            struct v2f{
                float4 pos: SV_POSITION;
                float3 worldNormal: TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i):  SV_TARGET{
                fixed3 worldNormal= normalize(i.worldNormal);

                #ifdef USING_DIRECTIONAL_LIGHT//如果使用的平行光
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                #else 
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                fixed3 diffuse=_LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                fixed3 viewDir=normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir=normalize(worldLightDir+viewDir);
                fixed3 specular=_LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                //处理光照衰减
                #ifdef USING_DIRECTIONAL_LIGHT//如果使用的平行光
                fixed atten=1.0;
                #else 
                    #if defined(POINT)//如果是点光
                        float3 lightCoord=mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
                        fixed atten=tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #elif defined(SPOT)
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                    #else 
                        fixed atten=1.0;
                    #endif
                #endif

                return fixed4((diffuse + specular) * atten, 1.0);
            }
           ENDCG
       }
   }
   Fallback "Specular"
}
