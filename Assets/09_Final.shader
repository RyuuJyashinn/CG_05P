Shader "Custom/09_Final"
{
    Properties
    {
        [Header(Base Properties)]
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainTex_ST ("Main Texture Tiling & Offset", Vector) = (1,1,0,0)
        _Color ("Main Color", Color) = (1,1,1,1)
        
        [Header(Ambient Lighting)]
        _AmbientColor ("Ambient Color", Color) = (0.3,0.3,0.3,1)
        _AmbientIntensity ("Ambient Intensity", Range(0,1)) = 0.3
        
        [Header(Diffuse Lighting)]
        _DiffuseIntensity ("Diffuse Intensity", Range(0,2)) = 1.0
        
        [Header(Specular Lighting)]
        _SpecularPower ("Specular Power", Range(1,256)) = 32
        _SpecularIntensity ("Specular Intensity", Range(0,2)) = 1.0
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        
        [Header(Toon Shading)]
        _ToonThreshold ("Toon Threshold", Range(0,1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 0.3)) = 0.1
        _ShadowIntensity ("Shadow Intensity", Range(0,1)) = 0.6
        _ShadowStrength ("Shadow Strength", Range(0,2)) = 1.0
        
        [Header(Rim Light)]
        _RimColor ("Rim Color", Color) = (0.8,0.8,1,1)
        _RimPower ("Rim Power", Range(0.1,10)) = 3.0
        _RimIntensity ("Rim Intensity", Range(0,5)) = 2.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST; 
            fixed4 _Color;
            fixed4 _AmbientColor;
            fixed4 _SpecularColor;
            fixed4 _RimColor;
            float _AmbientIntensity;
            float _DiffuseIntensity;
            float _SpecularPower;
            float _SpecularIntensity;
            float _ToonThreshold;
            float _ShadowSmoothness;
            float _ShadowIntensity;
            float _ShadowStrength;
            float _RimPower;
            float _RimIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
               
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(o.vertex));
                return o;
            }

            fixed4 CalculateAmbient()
            {
                return _AmbientColor * _AmbientIntensity;
            }

            fixed4 CalculateToonDiffuse(float3 worldNormal, float3 lightDir, fixed4 baseColor)
            {
                float NdotL = dot(normalize(worldNormal), lightDir);

                float shadowStart = _ToonThreshold - _ShadowSmoothness;
                float shadowEnd = _ToonThreshold + _ShadowSmoothness;
                float toonIntensity = smoothstep(shadowStart, shadowEnd, NdotL);

                fixed4 shadowColor = baseColor * _ShadowIntensity;
                fixed4 finalShadowColor = lerp(shadowColor, fixed4(0.1,0.1,0.1,1), saturate(_ShadowStrength - 1.0));
                
                fixed4 diffuseColor = lerp(finalShadowColor, baseColor, toonIntensity);
                return diffuseColor * _LightColor0 * _DiffuseIntensity;
            }

            fixed4 CalculateSpecular(float3 worldNormal, float3 lightDir, float3 viewDir)
            {
                float3 reflectDir = reflect(-lightDir, worldNormal);
                float specular = pow(saturate(dot(reflectDir, viewDir)), _SpecularPower);
                float toonSpecular = step(0.1, specular);
                return toonSpecular * _SpecularColor * _LightColor0 * _SpecularIntensity;
            }

            fixed4 CalculateRimLight(float3 worldNormal, float3 viewDir)
            {
                float rim = 1.0 - saturate(dot(normalize(worldNormal), viewDir));
                rim = pow(rim, _RimPower);
                rim *= _RimIntensity;
                return _RimColor * rim;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(i.viewDir);
         
                fixed4 texColor = tex2D(_MainTex, i.uv);
                fixed4 baseColor = texColor * _Color;
                
                fixed4 ambient = CalculateAmbient();
                fixed4 diffuse = CalculateToonDiffuse(worldNormal, lightDir, baseColor);
                fixed4 specular = CalculateSpecular(worldNormal, lightDir, viewDir);
                fixed4 rimLight = CalculateRimLight(worldNormal, viewDir);
                
                fixed4 finalColor = ambient + diffuse + specular + rimLight;
                finalColor.a = baseColor.a;
                
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}