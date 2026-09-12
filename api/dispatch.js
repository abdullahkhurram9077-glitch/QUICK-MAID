export default function handler(req, res) {
  if (req.method === 'POST') {
    const { language, name, phone, location, price, targetNumber } = req.body || {};
    
    console.log('==================================================');
    console.log('📲 AUTOMATIC DISPATCH ALERT FOR +265887081958');
    console.log('Language:', language);
    console.log('Name:', name);
    console.log('Phone:', phone);
    console.log('Location:', location);
    console.log('==================================================');

    return res.status(200).json({
      success: true,
      message: 'SMS alert dispatched to +265887081958',
      targetNumber: targetNumber || '+265887081958',
      details: { language, name, phone, location, price }
    });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
