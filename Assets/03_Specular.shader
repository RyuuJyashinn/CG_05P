Shader "Unlit/03_Specular"
{
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
                float3 normal : NORMAL;  // 添加法线数据
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;  // 添加世界法线
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);  // 转换法线到世界空间
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 worldNormal = normalize(i.worldNormal);  // 使用世界法线
                
                float3 reflectDir = reflect(-lightDir, worldNormal);  
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 20) * _LightColor0;
                
                return specular;
            }
            ENDCG
        }
    }
}