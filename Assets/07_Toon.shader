Shader "Unlit/05_Toon"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Color", Color) = (0.3,0.3,0.3,1)
        _AmbientIntensity ("Ambient Intensity", Range(0,1)) = 0.3
        _SpecularPower ("Specular Power", Range(1,128)) = 20
        _ToonThreshold ("Toon Threshold", Range(0,1)) = 0.5
        _ShadowIntensity ("Shadow Intensity", Range(0,1)) = 0.6
        _ShadowStrength ("Shadow Strength", Range(0,2)) = 1.0  // 新增：阴影强度倍增
    }
    
    SubShader
    {
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

         
            fixed4 _Color;
            fixed4 _AmbientColor;
            float _AmbientIntensity;
            float _SpecularPower;
            float _ToonThreshold;
            float _ShadowIntensity;
            float _ShadowStrength;  // 阴影强度控制

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

       
            fixed4 CalculateAmbient()
            {
                return _AmbientColor * _AmbientIntensity * _LightColor0;
            }

            fixed4 CalculateToonDiffuse(float3 worldNormal, float3 lightDir)
            {
                float intensity = dot(normalize(worldNormal), lightDir);
                float toonIntensity = step(_ToonThreshold, intensity);
                
                // 计算基础暗色
                fixed4 shadowColor = _Color * _ShadowIntensity;
                
                // 应用阴影强度控制
                fixed4 finalShadowColor = lerp(shadowColor, fixed4(0,0,0,1), _ShadowStrength - 1.0);
                finalShadowColor = max(finalShadowColor, fixed4(0,0,0,1));
                
                fixed4 diffuseColor = toonIntensity > 0 ? _Color : finalShadowColor;
                
                return diffuseColor * _LightColor0;
            }

      
            fixed4 CalculateToonSpecular(float3 worldNormal, float3 lightDir, float3 viewDir)
            {
                float3 reflectDir = reflect(-lightDir, worldNormal);
                float specularIntensity = pow(saturate(dot(reflectDir, viewDir)), _SpecularPower);
                float toonSpecular = step(_ToonThreshold, specularIntensity);
                
                return toonSpecular * _LightColor0;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);

                fixed4 ambient = CalculateAmbient();      
                fixed4 diffuse = CalculateToonDiffuse(worldNormal, lightDir);     
                fixed4 specular = CalculateToonSpecular(worldNormal, lightDir, viewDir); 

                fixed4 toon = ambient + diffuse + specular;
                return toon;
            }
            ENDCG
        }
    }
}