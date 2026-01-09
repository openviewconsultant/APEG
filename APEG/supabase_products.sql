-- Create Products Table safely
CREATE TABLE IF NOT EXISTS public.products (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    brand text,
    description text,
    price numeric NOT NULL,
    category text,
    image_url text,
    stock_quantity integer DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT products_pkey PRIMARY KEY (id)
);

-- Enable Row Level Security (if not already enabled)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Policy: Everyone can read products (drop if exists to avoid error on rerun)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.products;
CREATE POLICY "Enable read access for all users" ON public.products
    FOR SELECT USING (true);

-- SEED DATA - Insert only if table is empty or handle conflicts? 
-- Simple insert for demo purposes.
INSERT INTO public.products (name, brand, description, price, category, image_url, stock_quantity)
VALUES 
('Titleist Pro V1', 'Titleist', 'The #1 ball in golf. Extraordinary distance with consistent flight.', 54.99, 'Balls', 'https://example.com/prov1.jpg', 100),
('Stealth 2 Driver', 'TaylorMade', 'More carbon, more forgiveness. Fargiveness.', 599.99, 'Clubs', 'https://example.com/stealth2.jpg', 20),
('FootJoy Traditions', 'FootJoy', 'Classic styling with modern comfort.', 129.99, 'Footwear', 'https://example.com/fj.jpg', 50),
('Approach S62', 'Garmin', 'Premium GPS golf watch with mapping and stats.', 499.99, 'Technology', 'https://example.com/s62.jpg', 15),
('Odyssey White Hot OG', 'Odyssey', 'The most iconic insert of all time.', 249.99, 'Clubs', 'https://example.com/putter.jpg', 30),
('Taylormade TP5', 'TaylorMade', '5-layer tour performance.', 52.99, 'Balls', 'https://example.com/tp5.jpg', 80);
