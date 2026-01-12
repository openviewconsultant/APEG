-- 1. Add is_premium column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_premium boolean DEFAULT false;

-- 2. Update Products table RLS policies
-- First, ensure RLS is enabled
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Drop existing insert policy if any
DROP POLICY IF EXISTS "Premium users can insert products" ON public.products;

-- Create new policy: Only users with is_premium = true in their profile can insert
CREATE POLICY "Premium users can insert products" ON public.products
    FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() 
            AND is_premium = true
        )
    );

-- Also allow premium users to update/delete their own products (or any if it's admin style)
-- For now, let's keep it simple: premium can insert.
DROP POLICY IF EXISTS "Premium users can update products" ON public.products;
CREATE POLICY "Premium users can update products" ON public.products
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() 
            AND is_premium = true
        )
    );

-- 3. Helper to make a specific user premium (Replace with a real UUID if needed)
-- UPDATE public.profiles SET is_premium = true WHERE id = 'YOUR_USER_ID_HERE';

-- 4. Storage Bucket Policies for Product Images
-- First, create the bucket manually in Supabase Dashboard: Storage > New Bucket > "product-images"
-- Then run these policies:

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view product images (public read)
DROP POLICY IF EXISTS "Public can view product images" ON storage.objects;
CREATE POLICY "Public can view product images" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'product-images');

-- Policy: Premium users can upload product images
DROP POLICY IF EXISTS "Premium users can upload product images" ON storage.objects;
CREATE POLICY "Premium users can upload product images" ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'product-images' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() 
            AND is_premium = true
        )
    );

-- Policy: Premium users can update their uploaded images
DROP POLICY IF EXISTS "Premium users can update product images" ON storage.objects;
CREATE POLICY "Premium users can update product images" ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'product-images' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() 
            AND is_premium = true
        )
    );

-- Policy: Premium users can delete product images
DROP POLICY IF EXISTS "Premium users can delete product images" ON storage.objects;
CREATE POLICY "Premium users can delete product images" ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'product-images' AND
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() 
            AND is_premium = true
        )
    );
