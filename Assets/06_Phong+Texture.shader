Shader "Unlit/05_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Color", Color) = (0.3,0.3,0.3,1)
        _AmbientIntensity ("Ambient Intensity", Range(0,1)) = 0.3
        _SpecularPower ("Specular Power", Range(1,128)) = 20
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _AmbientColor;
            float _AmbientIntensity;
            float _SpecularPower;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 CalculateAmbient()
            {
                return _AmbientColor * _AmbientIntensity * _LightColor0;
            }

            fixed4 CalculateDiffuse(float3 worldNormal, float3 lightDir, fixed4 texColor)
            {
                float intensity = saturate(dot(normalize(worldNormal), lightDir));
                return texColor * _Color * intensity * _LightColor0;
            }

            fixed4 CalculateSpecular(float3 worldNormal, float3 lightDir, float3 viewDir)
            {
                float3 reflectDir = reflect(-lightDir, worldNormal);
                fixed4 specular = pow(saturate(dot(reflectDir, viewDir)), _SpecularPower) * _LightColor0;
                return specular;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ²ÉÑùÎÆÀí
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                float3 worldNormal = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);

                fixed4 ambient = CalculateAmbient();      
                fixed4 diffuse = CalculateDiffuse(worldNormal, lightDir, texColor);     
                fixed4 specular = CalculateSpecular(worldNormal, lightDir, viewDir); 

                fixed4 phong = ambient + diffuse + specular;
                return phong;
            }
            ENDCG
        }
    }
}